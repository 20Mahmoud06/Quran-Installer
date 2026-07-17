import sys
import os
import time
import requests
import json  
from PyQt6.QtWidgets import (QApplication, QWidget, QVBoxLayout, QLabel, 
                             QComboBox, QRadioButton, QProgressBar, QPushButton, 
                             QMessageBox, QHBoxLayout, QCompleter, QFileDialog)
from PyQt6.QtCore import Qt, QThread, pyqtSignal, QUrl, QStringListModel
from PyQt6.QtGui import QDesktopServices, QIcon, QFontDatabase, QFont

def get_resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

def load_json_file(filename, default_data):
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding='utf-8') as file:
                return json.load(file)
        except Exception as e:
            print(f"Error reading {filename}: {e}")
            return default_data
    else:
        print(f"Warning: {filename} not found in the directory.")
        return default_data

SURAHS = load_json_file(get_resource_path('surah.json'), [])
RECITERS = load_json_file(get_resource_path('clean_root_reciters.json'), {})

def normalize_arabic_text(text):
    if not text:
        return ""
    text = text.replace(" ", "").replace("-", "").replace("_", "")
    text = text.replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
    text = text.replace("ة", "ه")
    text = text.replace("ى", "ي")
    return text.lower()


class UpdateCheckerThread(QThread):
    update_available = pyqtSignal(str, str)

    def __init__(self, current_version):
        super().__init__()
        self.current_version = current_version

    def run(self):
        try:
            url = "https://api.github.com/repos/MOZA-18/Quran-Installer/releases/latest"
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                data = response.json()
                latest_version = data.get("name", "").strip("v")
                if not latest_version:
                    latest_version = data.get("tag_name", "").strip("v")
                release_url = data.get("html_url", "")
                
                if self.is_newer_version(self.current_version, latest_version):
                    self.update_available.emit(latest_version, release_url)
        except Exception:
            pass

    def is_newer_version(self, current, latest):
        try:
            curr_parts = [int(x) for x in current.split('.')]
            lat_parts = [int(x) for x in latest.split('.')]
            for c, l in zip(curr_parts, lat_parts):
                if l > c:
                    return True
                elif l < c:
                    return False
            return len(lat_parts) > len(curr_parts)
        except ValueError:
            return False


class DownloadWorker(QThread):
    progress_updated = pyqtSignal(int, str)
    max_progress_set = pyqtSignal(int)
    finished = pyqtSignal(str)
    cancelled = pyqtSignal()
    error_occurred = pyqtSignal(str)

    def __init__(self, mode, reciter_name, base_url, surahs_to_download, downloads_path):
        super().__init__()
        self.mode = mode
        safe_folder_name = "".join([c for c in reciter_name if c.isalpha() or c.isdigit() or c in (' ', '-', '_')]).strip()
        self.reciter_folder_name = safe_folder_name.replace(" ", "_")
        self.base_url = base_url
        self.surahs_to_download = surahs_to_download
        self.downloads_path = downloads_path
        
        self.is_paused = False
        self.is_cancelled = False

    def pause(self):
        self.is_paused = True

    def resume(self):
        self.is_paused = False

    def cancel(self):
        self.is_cancelled = True

    def run(self):
        qari_folder = os.path.join(self.downloads_path, self.reciter_folder_name)
        if not os.path.exists(qari_folder):
            os.makedirs(qari_folder)

        total_files = len(self.surahs_to_download)

        for index, surah in enumerate(self.surahs_to_download):
            if self.is_cancelled:
                break

            server_file_name = f"{surah}.mp3"
            download_url = f"{self.base_url.rstrip('/')}/{server_file_name}"
            
            surah_idx = int(surah) - 1
            if surah_idx < len(SURAHS):
                surah_name = SURAHS[surah_idx]
            else:
                surah_name = f"سورة_{surah}"
            
            beautiful_save_path = os.path.join(qari_folder, f"{surah} - {surah_name}.mp3")
            legacy_save_path = os.path.join(qari_folder, server_file_name) 

            if os.path.exists(beautiful_save_path) or os.path.exists(legacy_save_path):
                msg = f"تخطي: سورة {surah_name} موجودة بالفعل ({index+1}/{total_files})"
                self.progress_updated.emit(0, msg)
                continue

            try:
                response = requests.get(download_url, stream=True)
                response.raise_for_status()
                
                total_size = int(response.headers.get('content-length', 0))
                self.max_progress_set.emit(total_size if total_size > 0 else 100)
                
                downloaded = 0
                start_time = time.time()
                last_ui_update = 0
                file_incomplete = False

                with open(beautiful_save_path, 'wb') as file:
                    for chunk in response.iter_content(chunk_size=8192):
                        if self.is_cancelled:
                            file_incomplete = True
                            break
                        
                        while self.is_paused:
                            time.sleep(0.2)
                            if self.is_cancelled:
                                file_incomplete = True
                                break
                                
                        if file_incomplete:
                            break

                        if chunk:
                            file.write(chunk)
                            downloaded += len(chunk)
                            
                            current_time = time.time()
                            if current_time - last_ui_update > 0.2 or downloaded == total_size:
                                elapsed = current_time - start_time
                                
                                if elapsed > 0 and total_size > 0:
                                    speed = downloaded / elapsed
                                    remaining_bytes = total_size - downloaded
                                    eta_seconds = int(remaining_bytes / speed) if speed > 0 else 0
                                    percentage = int((downloaded / total_size) * 100)
                                    
                                    if eta_seconds < 60:
                                        eta_str = f"{eta_seconds} ثانية"
                                    else:
                                        eta_str = f"{eta_seconds//60} دقيقة و {eta_seconds%60} ثانية"
                                        
                                    status_msg = f"سورة {surah_name} ({index+1}/{total_files}) | {percentage}% | متبقي: {eta_str}"
                                else:
                                    status_msg = f"جاري تحميل سورة {surah_name} ({index+1}/{total_files})..."
                                
                                self.progress_updated.emit(downloaded, status_msg)
                                last_ui_update = current_time

                if file_incomplete and os.path.exists(beautiful_save_path):
                    os.remove(beautiful_save_path)
                    continue

            except Exception:
                self.progress_updated.emit(0, f"تخطي: سورة {surah_name} غير متوفرة لهذا القارئ")
                time.sleep(0.5)
                continue

        if self.is_cancelled:
            self.cancelled.emit()
        else:
            self.finished.emit(qari_folder)


class QuranDownloaderApp(QWidget):
    def __init__(self):
        super().__init__()
        self.current_version = "1.2.1"
        self.setWindowTitle("تحميل القرآن الكريم بضغطة واحدة")
        self.setWindowIcon(QIcon(get_resource_path("logo.png"))) 
        
        self.setMinimumSize(500, 550) 
        self.resize(600, 650)
        
        self.downloads_path = os.path.join(os.path.expanduser("~"), "Downloads", "Quran_Downloads")
        
        self.reciters_list = list(RECITERS.keys())
        self.surahs_list = [f"{i+1} - سورة {name}" for i, name in enumerate(SURAHS)]

        self.apply_design_system()
        self.init_ui()
        self.check_for_updates()

    def apply_design_system(self):
        qss = """
        QWidget {
            background-color: #fbf9f8;
            color: #4A4A4A;
            font-family: 'IBM Plex Sans Arabic', sans-serif;
            font-size: 16px;
        }
        QLabel {
            color: #1b1c1c;
            font-weight: 500;
        }
        QPushButton {
            background-color: #0F6E56;
            color: #ffffff;
            border-radius: 12px;
            padding: 10px;
            font-weight: bold;
            border: none;
        }
        QPushButton:hover {
            background-color: #086b53;
        }
        QPushButton:pressed {
            background-color: #005440;
        }
        QPushButton:disabled {
            background-color: #e4e2de;
            color: #c8c6c3;
        }
        QComboBox {
            background-color: #ffffff;
            border: 1px solid #bec9c3;
            border-radius: 8px;
            padding: 8px;
            color: #1b1c1c;
        }
        QComboBox:focus {
            border: 1px solid #0F6E56;
            background-color: #fbf9f8;
        }
        QComboBox::drop-down {
            border: none;
            width: 30px;
        }
        QProgressBar {
            border: none;
            background-color: #efeded;
            border-radius: 8px;
            text-align: center;
            color: #1b1c1c;
            font-weight: bold;
            min-height: 24px;
        }
        QProgressBar::chunk {
            background-color: #BA7517;
            border-radius: 8px;
        }
        QRadioButton {
            color: #1b1c1c;
            spacing: 10px;
        }
        QRadioButton::indicator {
            width: 18px;
            height: 18px;
            border-radius: 9px;
            border: 2px solid #bec9c3;
            background-color: #ffffff;
        }
        QRadioButton::indicator:checked {
            background-color: #0F6E56;
            border: 2px solid #0F6E56;
        }
        """
        self.setStyleSheet(qss)

    def setup_arabic_search(self, combo_box, items_list):
        combo_model = QStringListModel(items_list)
        combo_box.setModel(combo_model)
        
        completer_model = QStringListModel(items_list)
        completer = QCompleter(completer_model, combo_box)
        
        completer.setCompletionMode(QCompleter.CompletionMode.UnfilteredPopupCompletion)
        completer.setModelSorting(QCompleter.ModelSorting.UnsortedModel)
        
        combo_box.setCompleter(completer)
        
        def on_text_edited(text):
            norm_text = normalize_arabic_text(text)
            
            if not norm_text:
                completer_model.setStringList(items_list)
                return
                
            starts_with = []
            contains = []
            
            for item in items_list:
                norm_item = normalize_arabic_text(item)
                if norm_item.startswith(norm_text):
                    starts_with.append(item)
                elif norm_text in norm_item:
                    contains.append(item)
                    
            completer_model.setStringList(starts_with + contains)
            
        combo_box.lineEdit().textEdited.connect(on_text_edited)

    def init_ui(self):
        layout = QVBoxLayout()
        layout.setSpacing(16)
        layout.setContentsMargins(24, 24, 24, 24)

        layout.addWidget(QLabel("ابحث واختر القارئ:"))
        
        self.reciter_combo = QComboBox()
        self.reciter_combo.setEditable(True)
        self.setup_arabic_search(self.reciter_combo, self.reciters_list)
        self.reciter_combo.setCurrentIndex(-1) 
        self.reciter_combo.setMinimumHeight(40)
        layout.addWidget(self.reciter_combo)

        layout.addWidget(QLabel("خيارات التحميل:"))
        
        self.radio_full = QRadioButton("تحميل المصحف كاملاً")
        self.radio_full.setChecked(True)
        self.radio_full.toggled.connect(self.toggle_surah_select)
        layout.addWidget(self.radio_full)
        
        self.radio_single = QRadioButton("تحميل سورة معينة فقط")
        layout.addWidget(self.radio_single)

        self.surah_label = QLabel("ابحث واختر السورة:")
        self.surah_label.setEnabled(False)
        layout.addWidget(self.surah_label)
        
        self.surah_combo = QComboBox()
        self.surah_combo.setEditable(True)
        self.surah_combo.setEnabled(False)
        self.setup_arabic_search(self.surah_combo, self.surahs_list)
        self.surah_combo.setCurrentIndex(-1)
        self.surah_combo.setMinimumHeight(40)
        layout.addWidget(self.surah_combo)

        self.status_label = QLabel("جاهز للبدء")
        self.status_label.setStyleSheet("color: #6f7a74;")
        layout.addWidget(self.status_label)
        
        self.progress = QProgressBar()
        self.progress.setValue(0)
        layout.addWidget(self.progress)

        controls_layout = QHBoxLayout()
        controls_layout.setSpacing(16)
        
        self.btn_download = QPushButton("بدء التحميل")
        self.btn_download.setMinimumHeight(45)
        self.btn_download.clicked.connect(self.start_download)
        
        self.btn_pause = QPushButton("إيقاف مؤقت")
        self.btn_pause.setMinimumHeight(45)
        self.btn_pause.setEnabled(False)
        self.btn_pause.clicked.connect(self.toggle_pause)

        self.btn_cancel = QPushButton("إلغاء")
        self.btn_cancel.setMinimumHeight(45)
        self.btn_cancel.setEnabled(False)
        self.btn_cancel.clicked.connect(self.cancel_download)

        if not RECITERS:
            self.btn_download.setEnabled(False)
            self.status_label.setText("خطأ: لم يتم العثور على ملف clean_root_reciters.json")
            self.status_label.setStyleSheet("color: #ba1a1a;")
            
        controls_layout.addWidget(self.btn_download)
        controls_layout.addWidget(self.btn_pause)
        controls_layout.addWidget(self.btn_cancel)
        
        layout.addLayout(controls_layout)

        footer_layout = QHBoxLayout()
        self.btn_about = QPushButton("عن التطبيق")
        self.btn_about.setStyleSheet("background-color: transparent; color: #0F6E56; border: 1px solid #0F6E56;")
        self.btn_about.clicked.connect(self.show_about)
        
        self.btn_report = QPushButton("الإبلاغ عن مشكلة")
        self.btn_report.setStyleSheet("background-color: transparent; color: #0F6E56; border: 1px solid #0F6E56;")
        self.btn_report.clicked.connect(self.open_feedback)
        
        footer_layout.addWidget(self.btn_about)
        footer_layout.addWidget(self.btn_report)
        layout.addLayout(footer_layout)

        self.setLayout(layout)

    def check_for_updates(self):
        self.update_thread = UpdateCheckerThread(self.current_version)
        self.update_thread.update_available.connect(self.prompt_update)
        self.update_thread.start()

    def prompt_update(self, latest_version, release_url):
        reply = QMessageBox.question(
            self,
            "تحديث متاح",
            f"يتوفر إصدار جديد من التطبيق ({latest_version}).\nهل تريد تحديث التطبيق الآن؟",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            QDesktopServices.openUrl(QUrl(release_url))

    def show_about(self):
        about_text = (
            "تحميل القرآن الكريم بضغطة واحدة\n\n"
            "تطبيق صُمم لتسهيل تحميل سور القرآن الكريم بصوت القراء المفضلين.\n"
            "المطور: Moaz Waleed\n" 
            "للتواصل: moazw9969@gmail.com\n" 
            f"الإصدار: {self.current_version}"
        )
        QMessageBox.about(self, "عن التطبيق", about_text)

    def open_feedback(self):
        url = QUrl("https://github.com/MOZA-18/Quran-Installer/issues")
        QDesktopServices.openUrl(url)

    def toggle_surah_select(self):
        is_single = self.radio_single.isChecked()
        self.surah_combo.setEnabled(is_single)
        self.surah_label.setEnabled(is_single)

    def start_download(self):
        selected_reciter = self.reciter_combo.currentText().strip()
        
        if selected_reciter not in self.reciters_list:
            QMessageBox.critical(self, "خطأ", "الرجاء اختيار قارئ صحيح من القائمة")
            return
            
        base_url = RECITERS[selected_reciter]
        
        if self.radio_single.isChecked():
            selected_surah = self.surah_combo.currentText().strip()
            if selected_surah not in self.surahs_list:
                QMessageBox.critical(self, "خطأ", "الرجاء اختيار سورة صحيحة من القائمة")
                return
            
            surah_idx = self.surahs_list.index(selected_surah)
            surah_num = str(surah_idx + 1).zfill(3)
            surahs_to_download = [surah_num]
        else:
            surahs_to_download = [str(i).zfill(3) for i in range(1, 115)]

        chosen_dir = QFileDialog.getExistingDirectory(
            self, 
            "اختر مسار الحفظ",              
            self.downloads_path,            
            QFileDialog.Option.ShowDirsOnly 
        )
        
        if not chosen_dir:
            return 
            
        self.downloads_path = chosen_dir

        self.btn_download.setEnabled(False)
        self.btn_pause.setEnabled(True)
        self.btn_cancel.setEnabled(True)
        self.progress.setValue(0)
        
        self.worker = DownloadWorker(
            mode="single" if self.radio_single.isChecked() else "full",
            reciter_name=selected_reciter,
            base_url=base_url,
            surahs_to_download=surahs_to_download,
            downloads_path=self.downloads_path
        )
        
        self.worker.progress_updated.connect(self.update_ui_progress)
        self.worker.max_progress_set.connect(self.progress.setMaximum)
        self.worker.finished.connect(self.download_finished)
        self.worker.cancelled.connect(self.download_cancelled)
        
        self.worker.start()

    def toggle_pause(self):
        if hasattr(self, 'worker') and self.worker.isRunning():
            if self.worker.is_paused:
                self.worker.resume()
                self.btn_pause.setText("إيقاف مؤقت")
                self.status_label.setText("تم استئناف التحميل...")
            else:
                self.worker.pause()
                self.btn_pause.setText("استئناف")
                self.status_label.setText("تم إيقاف التحميل مؤقتاً...")

    def cancel_download(self):
        if hasattr(self, 'worker') and self.worker.isRunning():
            self.worker.cancel()
            self.btn_pause.setEnabled(False)
            self.btn_cancel.setEnabled(False)
            self.status_label.setText("جاري إيقاف التحميل وإلغاء العملية...")

    def update_ui_progress(self, value, text):
        self.progress.setValue(value)
        self.status_label.setText(text)

    def download_finished(self, folder_path):
        self.reset_buttons()
        self.status_label.setText("تم الانتهاء بنجاح!")
        QMessageBox.information(self, "نجاح", f"تم حفظ الملفات بنجاح في:\n{folder_path}")

    def download_cancelled(self):
        self.reset_buttons()
        self.status_label.setText("تم إلغاء التحميل.")
        QMessageBox.warning(self, "إلغاء", "تم إلغاء عملية التحميل وحذف الملفات غير المكتملة.")

    def reset_buttons(self):
        self.progress.setValue(0)
        self.btn_download.setEnabled(True)
        self.btn_pause.setEnabled(False)
        self.btn_cancel.setEnabled(False)
        self.btn_pause.setText("إيقاف مؤقت")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setLayoutDirection(Qt.LayoutDirection.RightToLeft)
    app.setStyle("Fusion") 
    
    window = QuranDownloaderApp()
    window.show()
    
    sys.exit(app.exec())