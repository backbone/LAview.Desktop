namespace LAview.Desktop {

	class AppSettings {
		//public static GLib.Settings settings;

		public static void init (string[] args) throws Error {
			SettingsSchemaSource sss = new SettingsSchemaSource.from_directory (AppDirs.settings_dir, null, false);
			//SettingsSchema schema = sss.lookup ("ws.backbone.laview.desktop-"+Config.VERSION_MAJOR.to_string(), false);
			if (sss.lookup == null)
				throw new FileError.NOENT ("Schema ID not found");

			//settings = new Settings.full (schema, null, null);
		}
	}
}
