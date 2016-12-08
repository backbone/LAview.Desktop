namespace Gettext {
	extern const string PACKAGE;
}

namespace LAview.Desktop {

	using Gtk, LAview.Desktop;

	/*namespace CommandlineOptions {
		// bool no_startup_progress = false;
		// string data_dir = null;
		bool show_version = false;
		// bool no_runtime_monitoring = false;

		OptionEntry[]? entries = null;

		OptionEntry[] get_options() {
			if (entries != null)
			return entries;

			// OptionEntry datadir = { "datadir", 'd', 0, OptionArg.FILENAME, &data_dir,
			//     N_("Path to LAview-Desktop's private data"), N_("DIRECTORY") };
			// entries += datadir;

			// OptionEntry no_monitoring = { "no-runtime-monitoring", 0, 0, OptionArg.NONE, &no_runtime_monitoring,
			//     N_("Do not monitor library directory at runtime for changes"), null };
			// entries += no_monitoring;

			// OptionEntry no_startup = { "no-startup-progress", 0, 0, OptionArg.NONE,
			//                            &no_startup_progress,
			//     N_("Don't display startup progress meter"), null };
			// entries += no_startup;

			OptionEntry version = { "version", 'V', 0, OptionArg.NONE, &show_version,
			                        N_("Show the application's version"), null };
			entries += version;

			OptionEntry terminator = { null, 0, 0, 0, null, null, null };
			entries += terminator;

			return entries;
		}
	}*/


	public class LAviewDesktopApp : Gtk.Application {

		MainWindow main_window;

		public LAviewDesktopApp () {
			Object(application_id: "ws.backbone.laview.desktop",
			       flags: ApplicationFlags.FLAGS_NONE);
		}

		~LAviewDesktopApp () {
			Resources.terminate ();
			AppCore.terminate ();
			AppDirs.terminate ();
		}

		protected override void activate () {
			try {
				main_window = new MainWindow (this);
				main_window.show_all ();
			} catch (Error e) {
				stderr.puts (_("Error: ")+e.message);
			}
		}

		public static int main (string[] args) {
			try {
				AppDirs.init (args);
				AppCore.init (args);
				Resources.init (args);
				//Gtk.init_with_args (ref args, _("[FILE]"), CommandlineOptions.get_options (), Gettext.PACKAGE);

				// Internationalization
				Intl.bindtextdomain (Gettext.PACKAGE, AppDirs.locale_dir);
				Intl.bind_textdomain_codeset (Gettext.PACKAGE, "UTF-8");

				var app = new LAviewDesktopApp ();
				return app.run (args);

			} catch (Error e) {
				stderr.puts (_("Error: ")+e.message+"\n");
				stderr.printf (_("Run '%s --help' to see a full list of available command line options.\n"), args[0]);
				return e.code;
			}
		}
	}
}
