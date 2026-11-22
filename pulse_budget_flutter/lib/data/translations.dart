enum AppLanguage { en, fr, ar }

extension AppLanguageX on AppLanguage {
  String get nativeName => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.fr => 'Français',
        AppLanguage.ar => 'العربية',
      };

  bool get isRtl => this == AppLanguage.ar;

  static AppLanguage fromCode(String? code) => switch (code) {
        'fr' => AppLanguage.fr,
        'ar' => AppLanguage.ar,
        _ => AppLanguage.en,
      };
}

class AppStrings {
  final AppLanguage lang;
  const AppStrings(this.lang);

  String get brandSub => switch (lang) {
        AppLanguage.fr => 'Gestionnaire hors ligne',
        AppLanguage.ar => 'إدارة الميزانية دون إنترنت',
        AppLanguage.en => 'Offline Money Manager',
      };

  String get navOverview => switch (lang) {
        AppLanguage.fr => 'Aperçu',
        AppLanguage.ar => 'نظرة عامة',
        AppLanguage.en => 'Overview',
      };

  String get navSpending => switch (lang) {
        AppLanguage.fr => 'Détails des dépenses',
        AppLanguage.ar => 'تفاصيل المصروفات',
        AppLanguage.en => 'Spending Details',
      };

  String get navEarnings => switch (lang) {
        AppLanguage.fr => 'Détails des revenus',
        AppLanguage.ar => 'تفاصيل الأرباح',
        AppLanguage.en => 'Earnings Details',
      };

  String get titleHome => switch (lang) {
        AppLanguage.fr => 'Aperçu du budget',
        AppLanguage.ar => 'نظرة عامة على الميزانية',
        AppLanguage.en => 'Budget Overview',
      };

  String get currentBalance => switch (lang) {
        AppLanguage.fr => 'Solde actuel',
        AppLanguage.ar => 'الرصيد الحالي',
        AppLanguage.en => 'Current Balance',
      };

  String get totalEarnings => switch (lang) {
        AppLanguage.fr => 'Total des revenus',
        AppLanguage.ar => 'إجمالي الأرباح',
        AppLanguage.en => 'Total Earnings',
      };

  String get totalSpendings => switch (lang) {
        AppLanguage.fr => 'Total des dépenses',
        AppLanguage.ar => 'إجمالي المصروفات',
        AppLanguage.en => 'Total Spendings',
      };

  String get addEarning => switch (lang) {
        AppLanguage.fr => 'Ajouter un revenu',
        AppLanguage.ar => 'إضافة ربح',
        AppLanguage.en => 'Add Earning',
      };

  String get addSpending => switch (lang) {
        AppLanguage.fr => 'Ajouter une dépense',
        AppLanguage.ar => 'إضافة مصروف',
        AppLanguage.en => 'Add Spending',
      };

  String get increasesBalance => switch (lang) {
        AppLanguage.fr => 'Augmente le solde',
        AppLanguage.ar => 'يزيد الرصيد',
        AppLanguage.en => 'Increases balance',
      };

  String get decreasesBalance => switch (lang) {
        AppLanguage.fr => 'Diminue le solde',
        AppLanguage.ar => 'ينقص الرصيد',
        AppLanguage.en => 'Decreases balance',
      };

  String get btnAdd => switch (lang) {
        AppLanguage.fr => '+ Ajouter',
        AppLanguage.ar => '+ إضافة',
        AppLanguage.en => '+ Add',
      };

  String get btnSpend => switch (lang) {
        AppLanguage.fr => '− Dépenser',
        AppLanguage.ar => '− صرف',
        AppLanguage.en => '− Spend',
      };

  String get earningNoteHint => switch (lang) {
        AppLanguage.fr => 'Note (facultatif, ex. Salaire)',
        AppLanguage.ar => 'ملاحظة (اختياري، مثل الراتب)',
        AppLanguage.en => 'Note (optional, e.g. Paycheck)',
      };

  String get spendingNoteHint => switch (lang) {
        AppLanguage.fr => 'Note (facultatif, ex. Courses)',
        AppLanguage.ar => 'ملاحظة (اختياري، مثل البقالة)',
        AppLanguage.en => 'Note (optional, e.g. Groceries)',
      };

  String get moneyAmount => switch (lang) {
        AppLanguage.fr => "Montant d'argent",
        AppLanguage.ar => 'قيمة المال',
        AppLanguage.en => 'Money Amount',
      };

  String get spendingChart => switch (lang) {
        AppLanguage.fr => 'Graphique des dépenses',
        AppLanguage.ar => 'مخطط المصروفات',
        AppLanguage.en => 'Spending Bar Chart',
      };

  String get earningsChart => switch (lang) {
        AppLanguage.fr => 'Graphique des revenus',
        AppLanguage.ar => 'مخطط الأرباح',
        AppLanguage.en => 'Earnings Bar Chart',
      };

  String get daily => switch (lang) {
        AppLanguage.fr => 'Quotidien',
        AppLanguage.ar => 'يومي',
        AppLanguage.en => 'Daily',
      };

  String get weekly => switch (lang) {
        AppLanguage.fr => 'Hebdo',
        AppLanguage.ar => 'أسبوعي',
        AppLanguage.en => 'Weekly',
      };

  String get monthly => switch (lang) {
        AppLanguage.fr => 'Mensuel',
        AppLanguage.ar => 'شهري',
        AppLanguage.en => 'Monthly',
      };

  String get today => switch (lang) {
        AppLanguage.fr => 'Auj.',
        AppLanguage.ar => 'اليوم',
        AppLanguage.en => 'Today',
      };

  String get thisWk => switch (lang) {
        AppLanguage.fr => 'Cette sem.',
        AppLanguage.ar => 'هذا الأسبوع',
        AppLanguage.en => 'This Wk',
      };

  String get last7d => switch (lang) {
        AppLanguage.fr => '7 derniers jours',
        AppLanguage.ar => 'آخر 7 أيام',
        AppLanguage.en => 'Last 7 days',
      };

  String get last6w => switch (lang) {
        AppLanguage.fr => '6 dernières semaines',
        AppLanguage.ar => 'آخر 6 أسابيع',
        AppLanguage.en => 'Last 6 weeks',
      };

  String get last6m => switch (lang) {
        AppLanguage.fr => '6 derniers mois',
        AppLanguage.ar => 'آخر 6 أشهر',
        AppLanguage.en => 'Last 6 months',
      };

  String get endingBalance => switch (lang) {
        AppLanguage.fr => 'Solde final',
        AppLanguage.ar => 'الرصيد النهائي',
        AppLanguage.en => 'Ending balance',
      };

  String get isDefault => switch (lang) {
        AppLanguage.fr => '★ Par défaut',
        AppLanguage.ar => '★ الافتراضي',
        AppLanguage.en => '★ Default',
      };

  String get setDefault => switch (lang) {
        AppLanguage.fr => 'Définir par défaut',
        AppLanguage.ar => 'تعيين كافتراضي',
        AppLanguage.en => 'Set as default',
      };

  String get spendingHistory => switch (lang) {
        AppLanguage.fr => 'Historique des dépenses',
        AppLanguage.ar => 'سجل المصروفات',
        AppLanguage.en => 'Spending History',
      };

  String get earningsHistory => switch (lang) {
        AppLanguage.fr => 'Historique des revenus',
        AppLanguage.ar => 'سجل الأرباح',
        AppLanguage.en => 'Earnings History',
      };

  String entriesCount(int n) => switch (lang) {
        AppLanguage.fr => n == 1 ? '1 entrée' : '$n entrées',
        AppLanguage.ar => n == 1 ? 'عملية واحدة' : '$n عمليات',
        AppLanguage.en => n == 1 ? '1 entry' : '$n entries',
      };

  String get noSpendings => switch (lang) {
        AppLanguage.fr => 'Aucune dépense enregistrée',
        AppLanguage.ar => 'لا توجد مصروفات مسجلة بعد',
        AppLanguage.en => 'No spendings recorded yet',
      };

  String get noEarnings => switch (lang) {
        AppLanguage.fr => 'Aucun revenu enregistré',
        AppLanguage.ar => 'لا توجد أرباح مسجلة بعد',
        AppLanguage.en => 'No earnings recorded yet',
      };

  String get emptyHint => switch (lang) {
        AppLanguage.fr => "Ajoutez une entrée depuis l'Aperçu pour la voir horodatée ici.",
        AppLanguage.ar => 'أضف عملية من النظرة العامة لتظهر هنا بالتوقيت الدقيق.',
        AppLanguage.en => 'Add an entry from Overview to see it timestamped here.',
      };

  String get defaultSpendingNote => switch (lang) {
        AppLanguage.fr => 'Dépense',
        AppLanguage.ar => 'مصروف',
        AppLanguage.en => 'Spending',
      };

  String get defaultEarningNote => switch (lang) {
        AppLanguage.fr => 'Revenu',
        AppLanguage.ar => 'ربح',
        AppLanguage.en => 'Earning',
      };

  String get darkMode => switch (lang) {
        AppLanguage.fr => 'Mode sombre',
        AppLanguage.ar => 'الوضع الداكن',
        AppLanguage.en => 'Dark Mode',
      };

  String get language => switch (lang) {
        AppLanguage.fr => 'Langue',
        AppLanguage.ar => 'اللغة',
        AppLanguage.en => 'Language',
      };

  String get localOnly => switch (lang) {
        AppLanguage.fr => "100 % local · Enregistré sur l'appareil",
        AppLanguage.ar => 'محلي 100% · محفوظ على الجهاز',
        AppLanguage.en => '100% Local · Saved on Device',
      };

  String get resetAll => switch (lang) {
        AppLanguage.fr => 'Réinitialiser les données',
        AppLanguage.ar => 'إعادة تعيين البيانات',
        AppLanguage.en => 'Reset All Data',
      };

  String get resetTitle => switch (lang) {
        AppLanguage.fr => 'Réinitialiser toutes les données ?',
        AppLanguage.ar => 'إعادة تعيين جميع البيانات؟',
        AppLanguage.en => 'Reset all budget data?',
      };

  String get resetBody => switch (lang) {
        AppLanguage.fr => 'Cela efface votre solde, vos paramètres et tout votre historique sur cet appareil.',
        AppLanguage.ar => 'سيؤدي هذا إلى مسح رصيدك وإعداداتك وسجل الأرباح والمصروفات على هذا الجهاز.',
        AppLanguage.en => 'This clears your balance, saved settings, and all spending and earnings history on this device.',
      };

  String get cancel => switch (lang) {
        AppLanguage.fr => 'Annuler',
        AppLanguage.ar => 'إلغاء',
        AppLanguage.en => 'Cancel',
      };

  String get resetConfirm => switch (lang) {
        AppLanguage.fr => 'Réinitialiser',
        AppLanguage.ar => 'إعادة تعيين',
        AppLanguage.en => 'Reset',
      };

  String get selectCurrency => switch (lang) {
        AppLanguage.fr => 'Choisir la devise',
        AppLanguage.ar => 'اختر العملة',
        AppLanguage.en => 'Select Currency',
      };

  String get currencySearchHint => switch (lang) {
        AppLanguage.fr => 'Rechercher un code, nom ou symbole (ex. EUR, MAD)',
        AppLanguage.ar => 'ابحث بالرمز أو الاسم (مثل MAD أو EUR)',
        AppLanguage.en => 'Search code, name, or symbol (e.g. EUR, MAD)',
      };

  String currencyCount(int matched, int total) => switch (lang) {
        AppLanguage.fr => '$matched sur $total devises',
        AppLanguage.ar => '$matched من $total عملة',
        AppLanguage.en => '$matched of $total currencies',
      };

  String get noCurrencies => switch (lang) {
        AppLanguage.fr => 'Aucune devise trouvée',
        AppLanguage.ar => 'لا توجد عملات مطابقة',
        AppLanguage.en => 'No matching currencies',
      };

  String get invalidAmount => switch (lang) {
        AppLanguage.fr => 'Saisissez un montant valide supérieur à 0',
        AppLanguage.ar => 'أدخل مبلغاً صحيحاً أكبر من 0',
        AppLanguage.en => 'Enter a valid amount greater than 0',
      };

  String addedEarning(String amt) => switch (lang) {
        AppLanguage.fr => '$amt ajoutés aux revenus',
        AppLanguage.ar => 'تمت إضافة $amt إلى الأرباح',
        AppLanguage.en => 'Added $amt to earnings',
      };

  String addedSpending(String amt) => switch (lang) {
        AppLanguage.fr => 'Dépense de $amt enregistrée',
        AppLanguage.ar => 'تم تسجيل مصروف $amt',
        AppLanguage.en => 'Logged $amt spending',
      };

  String get entryRemoved => switch (lang) {
        AppLanguage.fr => 'Entrée supprimée',
        AppLanguage.ar => 'تم حذف العملية',
        AppLanguage.en => 'Entry removed',
      };

  String alreadyDefault(String period) => switch (lang) {
        AppLanguage.fr => '$period est déjà par défaut',
        AppLanguage.ar => '$period هو الافتراضي بالفعل',
        AppLanguage.en => '$period is already your default',
      };

  String defaultSaved(String period) => switch (lang) {
        AppLanguage.fr => 'Par défaut défini sur $period',
        AppLanguage.ar => 'تم حفظ $period كافتراضي',
        AppLanguage.en => 'Default saved as $period',
      };

  String get clearedAll => switch (lang) {
        AppLanguage.fr => 'Toutes les données locales ont été effacées',
        AppLanguage.ar => 'تم مسح جميع البيانات المحلية',
        AppLanguage.en => 'All local budget data cleared',
      };

  String currencySet(String code, String name) => switch (lang) {
        AppLanguage.fr => 'Devise définie sur $code — $name',
        AppLanguage.ar => 'تم تغيير العملة إلى $code — $name',
        AppLanguage.en => 'Currency set to $code — $name',
      };

  List<String> get shortMonths => switch (lang) {
        AppLanguage.fr => const [
            'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
            'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
          ],
        AppLanguage.ar => const [
            'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
            'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
          ],
        AppLanguage.en => const [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
          ],
      };

  String get editEarning => switch (lang) {
        AppLanguage.fr => 'Modifier le revenu',
        AppLanguage.ar => 'تعديل الربح',
        AppLanguage.en => 'Edit Earning',
      };

  String get editSpending => switch (lang) {
        AppLanguage.fr => 'Modifier la dépense',
        AppLanguage.ar => 'تعديل المصروف',
        AppLanguage.en => 'Edit Spending',
      };

  String get save => switch (lang) {
        AppLanguage.fr => 'Enregistrer',
        AppLanguage.ar => 'حفظ',
        AppLanguage.en => 'Save',
      };

  String get entryUpdated => switch (lang) {
        AppLanguage.fr => 'Entrée mise à jour',
        AppLanguage.ar => 'تم تحديث العملية',
        AppLanguage.en => 'Entry updated',
      };

  String get exportBackup => switch (lang) {
        AppLanguage.fr => 'Exporter',
        AppLanguage.ar => 'تصدير نسخة',
        AppLanguage.en => 'Export Backup',
      };

  String get importBackup => switch (lang) {
        AppLanguage.fr => 'Importer',
        AppLanguage.ar => 'استيراد نسخة',
        AppLanguage.en => 'Import Backup',
      };

  String get exportDesc => switch (lang) {
        AppLanguage.fr => 'Copiez ce texte JSON et enregistrez-le dans un fichier ou une note sur votre nouvel appareil.',
        AppLanguage.ar => 'انسخ نص النسخة الاحتياطية هذا واحفظه في ملف أو ملاحظة لنقله إلى جهازك الجديد.',
        AppLanguage.en => 'Copy this backup JSON and save it to a note or .json file to move to your new device.',
      };

  String get importDesc => switch (lang) {
        AppLanguage.fr => 'Collez ici le texte JSON de sauvegarde exporté (compatible avec la version web et mobile).',
        AppLanguage.ar => 'الصق هنا نص النسخة الاحتياطية (متوافق مع نسخة الويب والهاتف).',
        AppLanguage.en => 'Paste your exported backup JSON below (works with backups from both the mobile and web app).',
      };

  String get copyBackup => switch (lang) {
        AppLanguage.fr => 'Copier',
        AppLanguage.ar => 'نسخ',
        AppLanguage.en => 'Copy',
      };

  String get pasteBackup => switch (lang) {
        AppLanguage.fr => 'Coller',
        AppLanguage.ar => 'لصق',
        AppLanguage.en => 'Paste',
      };

  String get restore => switch (lang) {
        AppLanguage.fr => 'Restaurer',
        AppLanguage.ar => 'استعادة',
        AppLanguage.en => 'Restore',
      };

  String get close => switch (lang) {
        AppLanguage.fr => 'Fermer',
        AppLanguage.ar => 'إغلاق',
        AppLanguage.en => 'Close',
      };

  String get backupCopied => switch (lang) {
        AppLanguage.fr => 'Sauvegarde copiée dans le presse-papiers',
        AppLanguage.ar => 'تم نسخ النسخة الاحتياطية إلى الحافظة',
        AppLanguage.en => 'Backup copied to clipboard',
      };

  String backupRestored(int count) => switch (lang) {
        AppLanguage.fr => 'Sauvegarde restaurée ($count entrées)',
        AppLanguage.ar => 'تمت استعادة النسخة ($count عمليات)',
        AppLanguage.en => 'Backup restored ($count entries)',
      };

  String get invalidBackup => switch (lang) {
        AppLanguage.fr => 'Format de sauvegarde JSON invalide',
        AppLanguage.ar => 'نص النسخة الاحتياطية غير صالح',
        AppLanguage.en => 'Invalid backup JSON format',
      };
}
