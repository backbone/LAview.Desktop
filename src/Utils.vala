namespace LAview.Desktop {

	namespace Utils {

		using Gtk;

		/**
		 * Resolve a path beginning with "~"
		 * Look at: https://github.com/ssokolow/gvrun/blob/master/process_runner.vala#L86
		 */
		#if (linux || UNIX || __unix__)
		static string expand_tilde (string path) {
			if (!path.has_prefix ("~")) return path; // Just pass paths through if they don't start with ~

			// Split the ~user portion from the path (Use / for the path if not present)
			string parts[2];
			if (!(Path.DIR_SEPARATOR_S in path)) {
				parts = { path.substring(1), Path.DIR_SEPARATOR_S };
			} else {
				string trimmed = path.substring(1);
				parts = trimmed.split(Path.DIR_SEPARATOR_S, 2);
			}
			warn_if_fail(parts.length == 2);

			// Handle both "~" and "~user" forms
			string home_path;
			if (parts[0] == "") {
				home_path = Environment.get_variable("HOME") ?? Environment.get_home_dir();
			} else {
				unowned Posix.Passwd _pw = Posix.getpwnam(parts[0]);
				home_path = (_pw == null) ? null : _pw.pw_dir;
			}

			// Fail safely if we couldn't look up a homedir
			if (home_path == null) {
				warning("Could not get homedir for user: %s", parts[0].length > 0 ? parts[0] : "<current user>");
				return path;
			} else {
				return home_path + Path.DIR_SEPARATOR_S + parts[1];
			}
		}
		#endif

		/**
		 * Open document.
		 * Idea borrowed from: https://github.com/ssokolow/gvrun/blob/master/process_runner.vala
		 */
		void open_document (string path, Window? parent_window = null) {
			#if (UNIX)
				const string[] OPENERS = {"xdg-open", "mimeopen", "open"};
				foreach (var opener in OPENERS) {
					if (Environment.find_program_in_path (opener) != null) {
						try {
							string[] argv = { opener, expand_tilde (path) };
							Process.spawn_async(null, argv, null, SpawnFlags.SEARCH_PATH, null, null);
						} catch (SpawnError err) {
							var msg = new MessageDialog (parent_window, DialogFlags.MODAL, MessageType.ERROR,
							                             ButtonsType.CLOSE, @"Error: $(err.message).");
							msg.response.connect ((response_id) => { msg.destroy (); } );
							msg.show ();
						}
						break;
					}
				}
			#elif (WINDOWS)
				Posix.system (@"start $path");
			#else
				assert_not_reached ();
			#endif
		}
	}
}
