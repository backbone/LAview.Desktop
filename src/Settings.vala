namespace LAview.Desktop {

	public class AppSettings {
		Settings settings;

		string _pdf_save_path = "";
		public string pdf_save_path {
			get { return _pdf_save_path; }
			set {
				if (settings != null) settings.set_string ("pdf-save-path", value);
				_pdf_save_path = value;
			}
		}

		public AppSettings () throws Error {
			string schema_file = AppDirs.settings_dir+"/gschemas.compiled";
			if (!File.new_for_path (schema_file).query_exists ())
				throw new IOError.NOT_FOUND ("File "+schema_file+" not found");
			SettingsSchemaSource sss = new SettingsSchemaSource.from_directory (AppDirs.settings_dir, null, false);
			string schema_name = "ws.backbone.laview.desktop-"+Config.VERSION_MAJOR.to_string();
			SettingsSchema schema = sss.lookup (schema_name, false);
			if (schema == null) {
				throw new IOError.NOT_FOUND ("Schema "+schema_name+" not found in "+schema_file);
			}
			settings = new Settings.full (schema, null, null);

			_pdf_save_path = settings.get_string("pdf-save-path");
			settings.changed["pdf-save-path"].connect (() => {
				_pdf_save_path = settings.get_string("pdf-save-path");
			});
		}
	}
}
