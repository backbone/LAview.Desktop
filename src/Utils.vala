namespace LAview.Desktop {

	namespace Utils {

		using Gtk;

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
							string[] argv = { opener, path };
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
