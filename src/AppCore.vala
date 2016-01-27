namespace LAview.Desktop {

	class AppCore {
		public static LAview.Core.Core core;
		public static AppSettings settings;

		public static void init (string[] args) throws Error {
			core = new LAview.Core.Core();
			settings = new AppSettings();
		}

	}
}
