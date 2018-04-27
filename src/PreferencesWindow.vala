namespace LAview.Desktop {

	using Gtk;

	/**
	 * Preferences window.
	 */
	public class PreferencesDialog {
		Dialog dialog;
		Gtk.ListStore liststore_data;
		Gtk.ListStore liststore_objects;
		FileChooserButton filechooserbutton_lyx;
		FileChooserButton filechooserbutton_latexmk;
		FileChooserButton filechooserbutton_perl;
		TreeView treeview_data;
		TreeView treeview_protocol_objects;

		public PreferencesDialog (Gtk.Application application, Window parent) throws Error {
			var builder = new Builder ();
			builder.add_from_file (AppDirs.ui_dir + "/laview-desktop.glade");
			builder.connect_signals (this);

			dialog = builder.get_object ("preferences_window") as Dialog;
			dialog.transient_for = parent;
			dialog.modal = true;
			//dialog.application = application;
			dialog.delete_event.connect ((source) => {return true;});
			liststore_data = builder.get_object ("liststore_data") as Gtk.ListStore;
			liststore_objects = builder.get_object ("liststore_protocol_objects") as Gtk.ListStore;
			filechooserbutton_lyx = builder.get_object ("filechooserbutton_lyx") as FileChooserButton;
			filechooserbutton_latexmk = builder.get_object ("filechooserbutton_latexmk") as FileChooserButton;
			filechooserbutton_perl = builder.get_object ("filechooserbutton_perl") as FileChooserButton;
			treeview_data = builder.get_object ("treeview_data") as TreeView;
			treeview_protocol_objects = builder.get_object ("treeview_protocol_objects") as TreeView;

			fill_liststore_data ();
			fill_liststore_objects ();

			filechooserbutton_lyx.set_filename (AppCore.core.lyx_path);
			filechooserbutton_latexmk.set_filename (AppCore.core.latexmk_pl_path);
			filechooserbutton_perl.set_filename (AppCore.core.perl_path);
		}

		void fill_liststore_data () {
			liststore_data.clear();
			TreeIter iter = TreeIter();
			foreach (var p in AppCore.core.data_plugins.entries) {
				liststore_data.append (out iter);
				liststore_data.set (iter, 0, p.value.get_readable_name ());
			}
		}

		void fill_liststore_objects () {
			liststore_objects.clear();
			TreeIter iter = TreeIter();
			foreach (var p in AppCore.core.object_plugins.entries) {
				liststore_objects.append (out iter);
				liststore_objects.set (iter, 0, p.value.get_readable_name ());
			}
		}

		public void show_all () {
			dialog.show_all ();
		}

		[CCode (instance_pos = -1)]
		public void button_close_clicked (Button button) {
			dialog.hide ();
		}

		[CCode (instance_pos = -1)]
		public void lyx_file_set (FileChooserButton chooser) {
			AppCore.core.lyx_path = chooser.get_filename ();
		}

		[CCode (instance_pos = -1)]
		public void latexmk_file_set (FileChooserButton chooser) {
			AppCore.core.latexmk_pl_path = chooser.get_filename ();
		}

		[CCode (instance_pos = -1)]
		public void perl_file_set (FileChooserButton chooser) {
			AppCore.core.perl_path = chooser.get_filename ();
		}

		int[] get_data_indices () {
			var selection = treeview_data.get_selection ();
			var selected_rows = selection.get_selected_rows (null);
			int[] indices = {};
			foreach (var r in selected_rows) {
				indices += r.get_indices()[0];
			}
			return indices;
		}

		int[] get_objects_indices () {
			var selection = treeview_protocol_objects.get_selection ();
			var selected_rows = selection.get_selected_rows (null);
			int[] indices = {};
			foreach (var r in selected_rows) {
				indices += r.get_indices()[0];
			}
			return indices;
		}

		void call_data_preferences () {
			var indices = get_data_indices ();
			for (int i = indices.length; i > 0;)
				foreach (var p in AppCore.core.data_plugins.entries)
					if (indices[--i] == 0) {
						try {
							p.value.preferences(dialog);
							break;
						} catch (Error err) {
							var msg = new MessageDialog (dialog, DialogFlags.MODAL, MessageType.ERROR,
							                             ButtonsType.CLOSE, _("Error: ")+err.message);
							msg.response.connect ((response_id) => { msg.destroy (); } );
							msg.show ();
						}
					}
		}

		void call_object_preferences () {
			var indices = get_objects_indices ();
			for (int i = indices.length; i > 0;)
				foreach (var p in AppCore.core.object_plugins.entries)
					if (indices[--i] == 0) {
						try {
							p.value.preferences(dialog);
							break;
						} catch (Error err) {
							var msg = new MessageDialog (dialog, DialogFlags.MODAL, MessageType.ERROR,
							                             ButtonsType.CLOSE, _("Error: ")+err.message);
							msg.response.connect ((response_id) => { msg.destroy (); } );
							msg.show ();
						}
					}
		}

		[CCode (instance_pos = -1)]
		public void button_data_preferences_clicked (Button button) {
			call_data_preferences();
		}

		[CCode (instance_pos = -1)]
		public void button_object_preferences_clicked (Button button) {
			call_object_preferences();
		}

		[CCode (instance_pos = -1)]
		public void data_row_activated (Gtk.TreeView treeview,
		                                Gtk.TreePath path,
		                                Gtk.TreeViewColumn column) {
			call_data_preferences();
		}

		[CCode (instance_pos = -1)]
		public void objects_row_activated (Gtk.TreeView treeview,
		                                   Gtk.TreePath path,
		                                   Gtk.TreeViewColumn column) {
			call_object_preferences();
		}

		[CCode (instance_pos = -1)]
		public void button_search_clicked (Button button) {

			#if (UNIX)
				var msg = new MessageDialog (dialog, DialogFlags.MODAL, MessageType.INFO,
				                             ButtonsType.CLOSE, _("You are on Unix, bro! :-)"));
				msg.response.connect ((response_id) => { msg.destroy (); } );
				msg.show ();
			#elif (WINDOWS)
				if (!File.new_for_path(AppCore.core.lyx_path).query_exists()) {
					string[] lyx_dirs = { "c:\\Program Files", "c:\\Program Files (x86)",
					                      "c:\\msys64\\mingw64", "c:\\msys64\\mingw32" };
					try {
						foreach (var directory in lyx_dirs) {
							Dir dir = Dir.open (directory, 0);
							string? name = null;

							while ((name = dir.read_name()) != null) {
								if (/^(lyx|mingw)/i.match(name)) {
									var lyx_path = directory+"\\"+name+"\\bin\\lyx.exe";
									if (File.new_for_path(lyx_path).query_exists()) {
										filechooserbutton_lyx.set_filename (lyx_path);
										AppCore.core.lyx_path = lyx_path;
										break;
									} else {
										name = null;
									}
								} else {
									name = null;
								}
							}
							if (name != null) break;
						}
					} catch (FileError err) {
					}
				}

				if (!File.new_for_path(AppCore.core.latexmk_pl_path).query_exists()) {
					string[] latexmk_pl_dirs = { "c:\\Program Files", "c:\\Program Files (x86)",
					                             "c:\\", "c:\\texlive" };
					try {
						foreach (var directory in latexmk_pl_dirs) {
							Dir dir = Dir.open (directory, 0);
							string? name = null;

							while ((name = dir.read_name()) != null) {
								if (/^(miktex|20[0-9][0-9])/i.match(name)) {
									string[] suffixes = { "scripts\\latexmk\\perl\\latexmk.pl",
									                      "texmkf-dist\\scripts\\latexmk\\latexmk.pl" };
									foreach (var suffix in suffixes) {
										var latexmk_pl_path = directory+"\\"+name+"\\"+suffix;
										if (File.new_for_path(latexmk_pl_path).query_exists()) {
											filechooserbutton_latexmk.set_filename (latexmk_pl_path);
											AppCore.core.latexmk_pl_path = latexmk_pl_path;
											break;
										} else {
											name = null;
										}
									}
									if (name != null) break;
								} else {
									name = null;
								}
							}
							if (name != null) break;
						}
					} catch (FileError err) {
					}
				}

				if (!File.new_for_path(AppCore.core.perl_path).query_exists()) {
					var path = AppDirs.exec_dir.get_path() + "\\perl.exe";
					if (File.new_for_path(path).query_exists()) {
						filechooserbutton_perl.set_filename (path);
						AppCore.core.perl_path = path;
					}
				}

				if (   !File.new_for_path(AppCore.core.lyx_path).query_exists()
				    || !File.new_for_path(AppCore.core.latexmk_pl_path).query_exists()
				    || !File.new_for_path(AppCore.core.perl_path).query_exists()) {
						var msg = new MessageDialog (dialog, DialogFlags.MODAL, MessageType.WARNING,
						                             ButtonsType.CLOSE, _("Warning: ")+_("Not all paths found."));
						msg.response.connect ((response_id) => { msg.destroy (); } );
						msg.show ();
				}
			#endif
		}
	}
}
