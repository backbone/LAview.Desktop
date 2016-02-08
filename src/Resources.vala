namespace LAview.Desktop {
	class Resources {
		public static Resource resource;

		public static void init (string[] args) throws Error {
			var resource_file = AppDirs.resource_dir+"/laview-desktop.gresource";
			resource = Resource.load (resource_file);
			resource._register();
		}

		public static void terminate () {
		}
	}
}
