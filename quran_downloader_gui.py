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
    "محمد سايد": "https://server16.mp3quran.net/m_sayed/Rewayat-Warsh-A-n-Nafi/",
    "عبدالرحمن السويّد": "https://server16.mp3quran.net/a_swaiyd/Rewayat-Hafs-A-n-Assem/",
    "عبدالإله بن عون": "https://server16.mp3quran.net/a_binaoun/Rewayat-Hafs-A-n-Assem/",
    "أحمد طالب بن حميد": "https://server16.mp3quran.net/a_binhameed/Rewayat-Hafs-A-n-Assem/",
    "نورين محمد صديق": "https://server16.mp3quran.net/nourin_siddig/Rewayat-Aldori-A-n-Abi-Amr/",
    "ماجد الزامل": "https://server9.mp3quran.net/zaml/",
    "القارئ ياسين": "https://server11.mp3quran.net/qari/",
    "ماهر شخاشيرو": "https://server10.mp3quran.net/shaksh/",
    "العشري عمران": "https://server9.mp3quran.net/omran/",
    "محمد المنشد": "https://server10.mp3quran.net/monshed/",
    "محمود الشيمي": "https://server10.mp3quran.net/sheimy/",
    "ياسر سلامة": "https://server12.mp3quran.net/salamah/Rewayat-Hafs-A-n-Assem/",
    "أخيل عبدالحي روا": "https://server12.mp3quran.net/malaysia/akil/",
    "أستاذ زامري": "https://server12.mp3quran.net/malaysia/zamri/",
    "خالد المهنا": "https://server11.mp3quran.net/mohna/",
    "العيون الكوشي": "https://server11.mp3quran.net/koshi/",
    "عادل الكلباني": "https://server8.mp3quran.net/a_klb/",
    "موسى بلال": "https://server11.mp3quran.net/bilal/",
    "حسين آل الشيخ": "https://server11.mp3quran.net/alshaik/",
    "حاتم فريد الواعر": "https://server11.mp3quran.net/hatem/",
    "إبراهيم الجرمي": "https://server11.mp3quran.net/jormy/",
    "محمود الرفاعي": "https://server11.mp3quran.net/mrifai/",
    "ناصر العبيد": "https://server11.mp3quran.net/obaid/",
    "واصل المذن": "https://server11.mp3quran.net/wasel/Rewayat-Hafs-A-n-Assem/",
    "توفيق الصايغ": "https://server6.mp3quran.net/twfeeq/",
    "إبراهيم الدوسري": "https://server10.mp3quran.net/ibrahim_dosri/Rewayat-Hafs-A-n-Assem/",
    "جمال شاكر عبدالله": "https://server6.mp3quran.net/jamal/",
    "جمعان العصيمي": "https://server6.mp3quran.net/jaman/",
    "رضية عبدالرحمن": "https://server12.mp3quran.net/malaysia/rziah/",
    "رقية سولونق": "https://server12.mp3quran.net/malaysia/rogiah/",
    "سابينة مامات": "https://server12.mp3quran.net/malaysia/mamat/",
    "سيدين عبدالرحمن": "https://server12.mp3quran.net/malaysia/sideen/",
    "عبدالغني عبدالله": "https://server12.mp3quran.net/malaysia/abdulgani/",
    "عبدالله فهمي": "https://server12.mp3quran.net/malaysia/fhmi/",
    "حمد الدغريري": "https://server6.mp3quran.net/hamad/",
    "محمد الحافظ": "https://server12.mp3quran.net/malaysia/hafz/",
    "محمد حفص علي": "https://server12.mp3quran.net/malaysia/hfs/",
    "محمد خير النور": "https://server12.mp3quran.net/malaysia/nor/",
    "يوسف بن نوح أحمد": "https://server8.mp3quran.net/noah/",
    "جمال الدين الزيلعي": "https://server11.mp3quran.net/zilaie/",
    "معيض الحارثي": "https://server8.mp3quran.net/harthi/",
    "محمد رشاد الشريف": "https://server10.mp3quran.net/rashad/",
    "إبراهيم الجبرين": "https://server6.mp3quran.net/jbreen/",
    "خالد الجليل": "https://server10.mp3quran.net/jleel/",
    "أحمد الطرابلسي": "https://server10.mp3quran.net/trabulsi/",
    "عبدالله الكندري": "https://server10.mp3quran.net/Abdullahk/",
    "أحمد عامر": "https://server10.mp3quran.net/Aamer/",
    "إبراهيم السعدان": "https://server10.mp3quran.net/IbrahemSadan/",
    "أحمد الحذيفي": "https://server8.mp3quran.net/ahmad_huth/",
    "محمد عثمان خان": "https://server6.mp3quran.net/khan/",
    "يوسف الدغوش": "https://server7.mp3quran.net/dgsh/",
    "الدوكالي محمد العالم": "https://server7.mp3quran.net/dokali/",
    "وشيار حيدر اربيلي": "https://server11.mp3quran.net/wishear/",
    "خالد القحطاني": "https://server10.mp3quran.net/qht/",
    "الفاتح محمد الزبير": "https://server6.mp3quran.net/fateh/",
    "عبدالله القرافي": "https://server16.mp3quran.net/a_alqrafi/Rewayat-Hafs-A-n-Assem/",
    "عبدالبديع غيلان": "https://server16.mp3quran.net/A-Ghailan/Rewayat-Hafs-A-n-Assem/",
    "محمد برهجي": "https://server16.mp3quran.net/M_Burhaji/Rewayat-Hafs-A-n-Assem/",
    "يوسف العيدروس": "https://server16.mp3quran.net/Y_ALaidroos/Rewayat-Hafs-A-n-Assem/",
    "حسن الدغريري": "https://server16.mp3quran.net/H-Aldaghriri/Rewayat-Hafs-A-n-Assem/",
    "محمد الفقيه": "https://server16.mp3quran.net/M_Alfaqih/Rewayat-Hafs-A-n-Assem/",
    "جنيد آدم عبدالله": "https://server16.mp3quran.net/J-Abdullah/Rewayat-Hafs-A-n-Assem/",
    "خالد الزيادي": "https://server16.mp3quran.net/K-Alzadi/Rewayat-Hafs-A-n-Assem/",
    "الوليد الشمسان": "https://server14.mp3quran.net/shamsan/Rewayat-Hafs-A-n-Assem/",
    "إبراهيم الشهري": "https://server16.mp3quran.net/Ibrahim-Al-Shahri/Rewayat-Hafs-A-n-Assem/",
    "عبدالرحمن بن عبدالرزاق البدر": "https://server16.mp3quran.net/A-AlBadr/Rewayat-Hafs-A-n-Assem/",
    "عليجان قوري حمدان": "https://server16.mp3quran.net/Alijon/Rewayat-Hafs-A-n-Assem/",
    "محمد الزبيدي": "https://server16.mp3quran.net/M-AlZubaidi/Rewayat-Hafs-A-n-Assem/",
    "عبد المجيب بنكيران": "https://server16.mp3quran.net/A-Benkirane/Rewayat-Warsh-A-n-Nafi/",
    "طارق عبدالغني دعوب": "https://server10.mp3quran.net/tareq/",
    "عاصم اللحیدان": "https://server7.mp3quran.net/asim/Rewayat-Hafs-A-n-Assem/",
    "محمود حرفوش": "https://server16.mp3quran.net/M-Harfoush/Rewayat-Hafs-A-n-Assem/",
    "عثمان الأنصاري": "https://server11.mp3quran.net/Othmn/",
    "بندر بليله": "https://server6.mp3quran.net/balilah/",
    "خالد الشريمي": "https://server12.mp3quran.net/shoraimy/",
    "وديع اليمني": "https://server6.mp3quran.net/wdee3/",
    "خالد عبدالكافي": "https://server11.mp3quran.net/kafi/",
    "رعد محمد الكردي": "https://server6.mp3quran.net/kurdi/",
    "عبدالرحمن العوسي": "https://server6.mp3quran.net/aloosi/",
    "خالد الغامدي": "https://server6.mp3quran.net/ghamdi/",
    "رمضان شكور": "https://server6.mp3quran.net/shakoor/",
    "عبدالمجيد الأركاني": "https://server7.mp3quran.net/m_arkani/",
    "محمد خليل القارئ": "https://server8.mp3quran.net/m_qari/",
    "خالد الوهيبي": "https://server11.mp3quran.net/whabi/",
    "رامي الدعيس": "https://server6.mp3quran.net/rami/",
    "هزاع البلوشي": "https://server11.mp3quran.net/hazza/",
    "عبدالرحمن الماجد": "https://server10.mp3quran.net/a_majed/",
    "مروان العكري": "https://server16.mp3quran.net/m_akri/Rewayat-Qalon-A-n-Nafi/",
    "خليفة الطنيجي": "https://server12.mp3quran.net/tnjy/",
    "سلمان العتيبي": "https://server11.mp3quran.net/salman/",
    "محمد رفعت": "https://server14.mp3quran.net/refat/",
    "عبدالله الموسى": "https://server14.mp3quran.net/mousa/Almusshaf-Al-Mo-lim/",
    "عبدالله الخلف": "https://server14.mp3quran.net/khalf/",
    "منصور السالمي": "https://server14.mp3quran.net/mansor/",
    "صلاح مصلي": "https://server14.mp3quran.net/musali/",
    "خالد الشارخ": "https://server14.mp3quran.net/sharekh/",
    "ناصر العصفور": "https://server14.mp3quran.net/alosfor/",
    "داود حمزة": "https://server9.mp3quran.net/hamza/",
    "محمد البخيت": "https://server14.mp3quran.net/bukheet/",
    "ناصر الماجد": "https://server14.mp3quran.net/nasser_almajed/",
    "أحمد السويلم": "https://server14.mp3quran.net/swlim/Rewayat-Hafs-A-n-Assem/",
    "إسلام صبحي": "https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/",
    "بدر التركي": "https://server10.mp3quran.net/bader/Rewayat-Hafs-A-n-Assem/",
    "هيثم الجدعاني": "https://server16.mp3quran.net/hitham/Rewayat-Hafs-A-n-Assem/",
    "أحمد خليل شاهين": "https://server16.mp3quran.net/shaheen/Rewayat-Hafs-A-n-Assem/",
    "سعد المقرن": "https://server16.mp3quran.net/saad/Rewayat-Hafs-A-n-Assem/",
    "أحمد النفيس": "https://server16.mp3quran.net/nufais/Rewayat-Hafs-A-n-Assem/",
    "رشيد إفراد": "https://server12.mp3quran.net/ifrad/",
    "عمر الدريويز": "https://server16.mp3quran.net/darweez/Rewayat-Hafs-A-n-Assem/",
    "عبدالعزيز العسيري": "https://server16.mp3quran.net/abdulazizasiri/Rewayat-Hafs-A-n-Assem/",
    "يونس اسويلص": "https://server16.mp3quran.net/souilass/Rewayat-Warsh-A-n-Nafi/",
    "أحمد ديبان": "https://server16.mp3quran.net/deban/Rewayat-Ibn-Jammaz-A-n-Abi-Ja-far/",
    "عبدالله كامل": "https://server16.mp3quran.net/kamel/Rewayat-Hafs-A-n-Assem/",
    "بيشه وا قادر الكردي": "https://server16.mp3quran.net/peshawa/Rewayat-Hafs-A-n-Assem/",
    "رشيد بلعالية": "https://server6.mp3quran.net/bl3/",
    "نذير المالكي": "https://server16.mp3quran.net//nathier/Rewayat-Hafs-A-n-Assem/",
    "عكاشة كميني": "https://server16.mp3quran.net/okasha/Rewayat-Albizi-A-n-Ibn-Katheer/",
    "هيثم الدخين": "https://server16.mp3quran.net/h_dukhain/Rewayat-Hafs-A-n-Assem/",
    "محمد أبو سنينة": "https://server16.mp3quran.net/sneineh/Rewayat-Qalon-A-n-Nafi/",
    "محمد الأمين قنيوة": "https://server16.mp3quran.net/qeniwa/Rewayat-Qalon-A-n-Nafi/",
    "محمود عبدالحكم": "https://server16.mp3quran.net/m_abdelhakam/Rewayat-Hafs-A-n-Assem/",
    "أحمد عيسى المعصراوي": "https://server16.mp3quran.net/a_maasaraawi/Rewayat-Rawh-A-n-Yakoob-Alhadrami/",
    "إبراهيم كشيدان": "https://server16.mp3quran.net/i_kshidan/Rewayat-Qalon-A-n-Nafi/",
    "زكريا حمامة": "https://server9.mp3quran.net/zakariya/",
    "هاشم أبو دلال": "https://server16.mp3quran.net/h_abudalal/Rewayat-Hafs-A-n-Assem/",
    "فؤاد الخامري": "https://server16.mp3quran.net/f_khamery/Rewayat-Hafs-A-n-Assem/",
    "سيد أحمد هاشمي": "https://server16.mp3quran.net/s_hashemi/Rewayat-Hafs-A-n-Assem/",
    "خالد كريم محمدي": "https://server16.mp3quran.net/kh_mohammadi/Rewayat-Hafs-A-n-Assem/",
    "مال الله عبدالرحمن الجابر": "https://server16.mp3quran.net/mal-allah_jaber/Rewayat-Hafs-A-n-Assem/",
    "سلمان الصديق": "https://server16.mp3quran.net/s_sadeiq/Rewayat-Hafs-A-n-Assem/",
    "حسن صالح": "https://server16.mp3quran.net/h_saleh/Rewayat-Hafs-A-n-Assem/",
    "عبدالرحمن الشحات": "https://server16.mp3quran.net/a_alshahhat/Rewayat-Hafs-A-n-Assem/",
    "عيسى عمر سناكو": "https://server16.mp3quran.net/i_sanankoua/Rewayat-Hafs-A-n-Assem/",
    "هارون بقائي": "https://server16.mp3quran.net/h_baqai/Rewayat-Hafs-A-n-Assem/",
    "عبدالله بخاري": "https://server16.mp3quran.net/a_bukhari/Rewayat-Hafs-A-n-Assem/",
    "صالح القريشي": "https://server16.mp3quran.net/s_alquraishi/Rewayat-Hafs-A-n-Assem/",
    "إبراهيم العسيري": "https://server6.mp3quran.net/3siri/",
    "سعد الغامدي": "https://server7.mp3quran.net/s_gmd/",
    "صالح الشمراني": "https://server16.mp3quran.net/shamrani/Rewayat-Hafs-A-n-Assem/",
    "فيصل الهاجري": "https://server16.mp3quran.net/f_hajry/Rewayat-Hafs-A-n-Assem/",
    "أنس العمادي": "https://server16.mp3quran.net/a_alemadi/Rewayat-Hafs-A-n-Assem/",
    "عبدالملك العسكر": "https://server16.mp3quran.net/a_alaskar/Rewayat-Hafs-A-n-Assem/",
    "عبدالكريم الحازمي": "https://server16.mp3quran.net/a_alhazmi/Rewayat-Hafs-A-n-Assem/",
    "هشام الهراز": "https://server16.mp3quran.net/H-Lharraz/Rewayat-Warsh-A-n-Nafi/",
    "عبدالله المشعل": "https://server16.mp3quran.net/a-almishal/Rewayat-Hafs-A-n-Assem/",
    "عبدالعزيز سحيم": "https://server16.mp3quran.net/a_sheim/Rewayat-Warsh-A-n-Nafi/",
    "سعود الشريم": "https://server7.mp3quran.net/shur/",
    "سهل ياسين": "https://server6.mp3quran.net/shl/",
    "زكي داغستاني": "https://server9.mp3quran.net/zaki/",
    "سامي الحسن": "https://server8.mp3quran.net/sami_hsn/",
    "سامي الدوسري": "https://server8.mp3quran.net/sami_dosr/",
    "سيد رمضان": "https://server12.mp3quran.net/sayed/",
    "شعبان الصياد": "https://server11.mp3quran.net/shaban/",
    "شيرزاد عبدالرحمن طاهر": "https://server12.mp3quran.net/taher/",
    "صابر عبدالحكم": "https://server12.mp3quran.net/hkm/",
    "شيخ أبو بكر الشاطري": "https://server11.mp3quran.net/shatri/",
    "صالح الصاهود": "https://server8.mp3quran.net/sahood/",
    "صالح آل طالب": "https://server9.mp3quran.net/tlb/",
    "صالح الهبدان": "https://server6.mp3quran.net/habdan/",
    "صلاح البدير": "https://server6.mp3quran.net/s_bud/",
    "صلاح الهاشم": "https://server12.mp3quran.net/salah_hashim_m/Rewayat-Qalon-A-n-Nafi/",
    "صلاح بو خاطر": "https://server8.mp3quran.net/bu_khtr/",
    "مختار الحاج": "https://server16.mp3quran.net/mukhtar_haj/Rewayat-Hafs-A-n-Assem/",
    "عادل ريان": "https://server8.mp3quran.net/ryan/",
    "عبدالبارئ الثبيتي": "https://server6.mp3quran.net/thubti/",
    "أحمد بن علي العجمي": "https://server10.mp3quran.net/ajm/",
    "عبدالبارئ محمد": "https://server12.mp3quran.net/bari/Almusshaf-Al-Mo-lim/",
    "عبدالباسط عبدالصمد": "https://server7.mp3quran.net/basit/",
    "عبدالرحمن السديس": "https://server11.mp3quran.net/sds/",
    "عبدالعزيز الأحمد": "https://server11.mp3quran.net/a_ahmed/",
    "عبدالعزيز الزهراني": "https://server9.mp3quran.net/zahrani/",
    "عبدالله البريمي": "https://server8.mp3quran.net/brmi/",
    "عبدالله البعيجان": "https://server8.mp3quran.net/buajan/",
    "عبدالله المطرود": "https://server8.mp3quran.net/mtrod/",
    "أحمد الحواشي": "https://server11.mp3quran.net/hawashi/",
    "عبدالله بصفر": "https://server6.mp3quran.net/bsfr/",
    "عبدالله خياط": "https://server12.mp3quran.net/kyat/",
    "عبدالله عواد الجهني": "https://server13.mp3quran.net/jhn/",
    "عبدالله غيلان": "https://server8.mp3quran.net/gulan/",
    "عبدالرشيد صوفي": "https://server16.mp3quran.net/soufi/Rewayat-Hafs-A-n-Assem/",
    "عبدالمحسن الحارثي": "https://server6.mp3quran.net/mohsin_harthi/",
    "عبدالمحسن القاسم": "https://server8.mp3quran.net/qasm/",
    "عبدالمحسن العسكر": "https://server6.mp3quran.net/askr/",
    "عبدالمحسن العبيكان": "https://server12.mp3quran.net/obk/",
    "أحمد سعود": "https://server11.mp3quran.net/saud/",
    "عبدالهادي أحمد كناكري": "https://server6.mp3quran.net/kanakeri/",
    "عبدالودود حنيف": "https://server8.mp3quran.net/wdod/",
    "عبدالولي الأركاني": "https://server6.mp3quran.net/arkani/",
    "علي أبو هاشم": "https://server9.mp3quran.net/abo_hashim/",
    "علي بن عبدالرحمن الحذيفي": "https://server9.mp3quran.net/hthfi/Rewayat-Sho-bah-A-n-Asim/",
    "علي جابر": "https://server11.mp3quran.net/a_jbr/",
    "علي حجاج السويسي": "https://server9.mp3quran.net/hajjaj/",
    "عماد زهير حافظ": "https://server6.mp3quran.net/hafz/",
    "عبدالعزيز التركي": "https://server16.mp3quran.net/a_turki/Rewayat-Hafs-A-n-Assem/",
    "أحمد صابر": "https://server8.mp3quran.net/saber/",
    "عمر القزابري": "https://server9.mp3quran.net/omar_warsh/",
    "فارس عباد": "https://server8.mp3quran.net/frs_a/",
    "فهد العتيبي": "https://server8.mp3quran.net/fahad_otibi/",
    "فهد الكندري": "https://server11.mp3quran.net/kndri/",
    "فواز الكعبي": "https://server8.mp3quran.net/fawaz/",
    "لافي العوني": "https://server6.mp3quran.net/lafi/",
    "ناصر القطامي": "https://server6.mp3quran.net/qtm/",
    "نبيل الرفاعي": "https://server9.mp3quran.net/nabil/",
    "نعمة الحسان": "https://server8.mp3quran.net/namh/",
    "هاني الرفاعي": "https://server8.mp3quran.net/hani/",
    "أحمد نعينع": "https://server11.mp3quran.net/ahmad_nu/",
    "وليد الدليمي": "https://server8.mp3quran.net/dlami/",
    "وليد النائحي": "https://server9.mp3quran.net/waleed/",
    "ياسر الدوسري": "https://server11.mp3quran.net/yasser/",
    "ياسر القرشي": "https://server9.mp3quran.net/qurashi/",
    "ياسر الفيلكاوي": "https://server6.mp3quran.net/fyl/",
    "ياسر المزروعي ": "https://server9.mp3quran.net/mzroyee/",
    "يحيى حوا": "https://server12.mp3quran.net/yahya/",
    "يوسف الشويعي": "https://server9.mp3quran.net/yousef/",
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