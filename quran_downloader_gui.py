import sys
import os
import time
import requests
from PyQt6.QtWidgets import (QApplication, QWidget, QVBoxLayout, QLabel, 
                             QComboBox, QRadioButton, QProgressBar, QPushButton, 
                             QMessageBox, QHBoxLayout, QCompleter)
from PyQt6.QtCore import Qt, QThread, pyqtSignal

# The 114 Surahs of the Holy Quran
SURAHS = [
    "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس",
    "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه",
    "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم",
    "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر",
    "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق",
    "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة",
    "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج",
    "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس",
    "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد",
    "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات",
    "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر",
    "المسد", "الإخلاص", "الفلق", "الناس"
]

RECITERS = {
    "إبراهيم الأخضر": "https://server6.mp3quran.net/akdr/",
    "أكرم العلاقمي": "https://server9.mp3quran.net/akrm/",
    "ماجد العنزي": "https://server8.mp3quran.net/majd_onazi/",
    "ماهر المعيقلي": "https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/",
    "محمد الأيراوي": "https://server6.mp3quran.net/earawi/",
    "محمد البراك": "https://server13.mp3quran.net/braak/",
    "محمد الطبلاوي": "https://server12.mp3quran.net/tblawi/Al-Mojawwad/",
    "محمد اللحيدان": "https://server8.mp3quran.net/lhdan/",
    "محمد المحيسني": "https://server11.mp3quran.net/mhsny/",
    "محمد أيوب": "https://server16.mp3quran.net/ayyoub2/Rewayat-Hafs-A-n-Assem/",
    "الحسيني العزازي": "https://server8.mp3quran.net/3zazi/",
    "محمد صالح عالم شاه": "https://server12.mp3quran.net/shah/",
    "محمد جبريل": "https://server8.mp3quran.net/jbrl/",
    "محمد صديق المنشاوي": "https://server10.mp3quran.net/minsh/Almusshaf-Al-Mo-lim/",
    "محمد عبدالكريم": "https://server12.mp3quran.net/m_krm/Rewayat-Warsh-A-n-Nafi-Men-Tariq-Abi-Baker-Alasbahani/",
    "محمد عبدالحكيم سعيد العبدالله": "https://server9.mp3quran.net/abdullah/Rewayat-AlDorai-A-n-Al-Kisa-ai/",
    "محمود خليل الحصري": "https://server13.mp3quran.net/husr/Rewayat-Qalon-A-n-Nafi/",
    "إدريس أبكر": "https://server6.mp3quran.net/abkr/",
    "محمود علي البنا": "https://server8.mp3quran.net/bna/Almusshaf-Al-Mojawwad/",
    "مشاري العفاسي": "https://server8.mp3quran.net/afs/Rewayat-AlDorai-A-n-Al-Kisa-ai/",
    "مصطفى إسماعيل": "https://server8.mp3quran.net/mustafa/Almusshaf-Al-Mojawwad/",
    "مصطفى اللاهوني": "https://server6.mp3quran.net/lahoni/",
    "مصطفى رعد العزاوي": "https://server8.mp3quran.net/ra3ad/",
    "معمر الأندونيسي": "https://server6.mp3quran.net/muamr/",
    "مفتاح السلطني": "https://server14.mp3quran.net/muftah_sultany/Rewayat_Ibn-Thakwan-A-n-Ibn-Amer/",
    "الزين محمد أحمد": "https://server9.mp3quran.net/alzain/",
    "ياسر الدوسري": "https://server11.mp3quran.net/yasser/",
    "ياسر القرشي": "https://server9.mp3quran.net/qurashi/",
    "ياسر الفيلكاوي": "https://server6.mp3quran.net/fyl/",
    "عبدالله عبدل": "https://server16.mp3quran.net/a_abdl/Rewayat-Hafs-A-n-Assem/"
}

class DownloadWorker(QThread):
    """
    Background worker thread to handle downloading without freezing the UI.
    PyQt requires UI updates to happen through signals.
    """
    progress_updated = pyqtSignal(int, str)
    max_progress_set = pyqtSignal(int)
    finished = pyqtSignal(str)
    error_occurred = pyqtSignal(str)

    def __init__(self, mode, reciter_name, base_url, surahs_to_download, downloads_path):
        super().__init__()
        self.mode = mode
        self.reciter_name = reciter_name
        self.base_url = base_url
        self.surahs_to_download = surahs_to_download
        self.downloads_path = downloads_path

    def run(self):
        qari_folder = os.path.join(self.downloads_path, self.reciter_name.replace(" ", "_"))
        if not os.path.exists(qari_folder):
            os.makedirs(qari_folder)

        total_files = len(self.surahs_to_download)

        for index, surah in enumerate(self.surahs_to_download):
            server_file_name = f"{surah}.mp3"
            download_url = f"{self.base_url.rstrip('/')}/{server_file_name}"
            
            surah_idx = int(surah) - 1
            surah_name = SURAHS[surah_idx]
            
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

                with open(beautiful_save_path, 'wb') as file:
                    for chunk in response.iter_content(chunk_size=8192):
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

            except Exception as e:
                self.progress_updated.emit(0, f"خطأ في تحميل سورة {surah_name}")
                time.sleep(1)
                continue

        self.finished.emit(qari_folder)

class QuranDownloaderApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("تحميل القرآن الكريم بضغطة واحدة")
        self.setFixedSize(500, 420)
        
        self.downloads_path = os.path.join(os.path.expanduser("~"), "Downloads", "Quran_Downloads")
        
        self.reciters_list = list(RECITERS.keys())
        self.surahs_list = [f"{i+1} - سورة {name}" for i, name in enumerate(SURAHS)]

        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout()
        layout.setSpacing(15)
        layout.setContentsMargins(20, 20, 20, 20)

        # 1. Reciter Selection (Native Right-to-Left typing and Autocomplete)
        layout.addWidget(QLabel("ابحث واختر القارئ:"))
        
        self.reciter_combo = QComboBox()
        self.reciter_combo.setEditable(True)
        self.reciter_combo.addItems(self.reciters_list)
        self.reciter_combo.setCurrentIndex(-1) # Start empty
        
        # Add Search/Autocomplete functionality
        reciter_completer = QCompleter(self.reciters_list)
        reciter_completer.setCaseSensitivity(Qt.CaseSensitivity.CaseInsensitive)
        reciter_completer.setFilterMode(Qt.MatchFlag.MatchContains)
        self.reciter_combo.setCompleter(reciter_completer)
        layout.addWidget(self.reciter_combo)

        # 2. Download Mode Selection
        layout.addWidget(QLabel("خيارات التحميل:"))
        
        self.radio_full = QRadioButton("تحميل المصحف كاملاً")
        self.radio_full.setChecked(True)
        self.radio_full.toggled.connect(self.toggle_surah_select)
        layout.addWidget(self.radio_full)
        
        self.radio_single = QRadioButton("تحميل سورة معينة فقط")
        layout.addWidget(self.radio_single)

        # 3. Surah Selection
        self.surah_label = QLabel("ابحث واختر السورة:")
        self.surah_label.setEnabled(False)
        layout.addWidget(self.surah_label)
        
        self.surah_combo = QComboBox()
        self.surah_combo.setEditable(True)
        self.surah_combo.addItems(self.surahs_list)
        self.surah_combo.setCurrentIndex(-1)
        self.surah_combo.setEnabled(False)
        
        surah_completer = QCompleter(self.surahs_list)
        surah_completer.setCaseSensitivity(Qt.CaseSensitivity.CaseInsensitive)
        surah_completer.setFilterMode(Qt.MatchFlag.MatchContains)
        self.surah_combo.setCompleter(surah_completer)
        layout.addWidget(self.surah_combo)

        # 4. Progress and Status
        self.status_label = QLabel("جاهز للبدء")
        self.status_label.setStyleSheet("color: gray;")
        layout.addWidget(self.status_label)
        
        self.progress = QProgressBar()
        self.progress.setValue(0)
        layout.addWidget(self.progress)

        # 5. Download Button
        self.btn_download = QPushButton("بدء التحميل بضغطة واحدة")
        self.btn_download.setMinimumHeight(40)
        self.btn_download.clicked.connect(self.start_download)
        layout.addWidget(self.btn_download)

        self.setLayout(layout)

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

        self.btn_download.setEnabled(False)
        self.progress.setValue(0)
        
        # Start Worker Thread
        self.worker = DownloadWorker(
            mode="single" if self.radio_single.isChecked() else "full",
            reciter_name=selected_reciter,
            base_url=base_url,
            surahs_to_download=surahs_to_download,
            downloads_path=self.downloads_path
        )
        
        # Connect signals
        self.worker.progress_updated.connect(self.update_ui_progress)
        self.worker.max_progress_set.connect(self.progress.setMaximum)
        self.worker.finished.connect(self.download_finished)
        
        self.worker.start()

    def update_ui_progress(self, value, text):
        self.progress.setValue(value)
        self.status_label.setText(text)

    def download_finished(self, folder_path):
        self.progress.setValue(0)
        self.btn_download.setEnabled(True)
        self.status_label.setText("تم الانتهاء بنجاح!")
        QMessageBox.information(self, "نجاح", f"تم حفظ الملفات بنجاح في:\n{folder_path}")


if __name__ == "__main__":
    # Initialize the PyQt Application
    app = QApplication(sys.argv)
    
    # Enforce Right-to-Left layout globally for the entire app!
    app.setLayoutDirection(Qt.LayoutDirection.RightToLeft)
    
    # Apply a cleaner, more modern native style
    app.setStyle("Fusion") 
    
    window = QuranDownloaderApp()
    window.show()
    
    sys.exit(app.exec())