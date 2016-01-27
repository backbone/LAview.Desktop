namespace LAview.Desktop {

	public class AppSettings {
		Settings settings;

		string _pdf_save_path;
		public string pdf_save_path {
			get { return _pdf_save_path; }
			set {
				if (settings != null) settings.set_string ("pdf-save-path", value);
				_pdf_save_path = value;
			}
			default = "";
		}

		public AppSettings () throws Error {
			SettingsSchemaSource sss = new SettingsSchemaSource.from_directory (AppDirs.settings_dir, null, false);
			SettingsSchema schema = sss.lookup ("ws.backbone.laview.desktop-"+Config.VERSION_MAJOR.to_string(), false);
			if (schema == null) {
				stderr.printf ("ID not found.\n");
				throw new IOError.NOT_FOUND ("File "+AppDirs.settings_dir+"/gschemas.compiled not found");
			}
			settings = new Settings.full (schema, null, null);

			_pdf_save_path = settings.get_string("pdf-save-path");
			settings.changed["pdf-save-path"].connect (() => {
				_pdf_save_path = settings.get_string("pdf-save-path");
			});
		}
	}
}
