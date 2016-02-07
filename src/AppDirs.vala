namespace LAview.Desktop {

	class AppDirs {
		private const string DEFAULT_DATA_DIR = ".texreport-gtk";

		public static File exec_file;
		public static File exec_dir;
		public static File common_dir;
		public static string resource_dir;
		public static string ui_dir;
		public static string locale_dir;
		public static string settings_dir;

		public static void init (string[] args) {
			exec_file = File.new_for_path (Environment.find_program_in_path (args[0]));
			exec_dir = exec_file.get_parent ();
			common_dir = exec_dir.get_parent ();
			resource_dir = Path.build_path (Path.DIR_SEPARATOR_S, common_dir.get_path(),
			                                "share/laview-desktop-"+Config.VERSION_MAJOR.to_string());
			ui_dir = resource_dir + "/ui";
			locale_dir = Path.build_path (Path.DIR_SEPARATOR_S, common_dir.get_path(), "share/locale");
			settings_dir = Path.build_path (Path.DIR_SEPARATOR_S, common_dir.get_path(), "share/glib-2.0/schemas");
			string w32dhack_sdir = settings_dir+"/laview-desktop-"+Config.VERSION_MAJOR.to_string();
			if (File.new_for_path(w32dhack_sdir+"/gschemas.compiled").query_exists ())
				settings_dir = w32dhack_sdir;
		}

		public static void terminate () {
		}
	}
}
