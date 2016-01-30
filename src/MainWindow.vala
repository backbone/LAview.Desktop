namespace LAview.Desktop {

	using Gtk, LAview, Core;

	/**
	 * Main LAview Desktop window.
	 */
	public class MainWindow {

		ApplicationWindow window;
		PreferencesDialog pref_dialog;
		AboutDialogWindow about_dialog;
		SubprocessDialog subprocess_dialog;
		Gtk.Statusbar statusbar;
		Gtk.ListStore liststore_templates;
		Gtk.ListStore liststore_doc_objects;
		TreeView treeview_templates;
		TreeView treeview_objects;

		public MainWindow (Gtk.Application application) throws Error {
			var builder = new Builder ();
			builder.add_from_file (AppDirs.ui_dir + "/laview-desktop.glade");
			builder.connect_signals (this);

			window = builder.get_object ("main_window") as ApplicationWindow;
			statusbar = builder.get_object ("statusbar") as Statusbar;
			liststore_templates = builder.get_object ("liststore_templates") as Gtk.ListStore;
			liststore_doc_objects = builder.get_object ("liststore_objects") as Gtk.ListStore;
			treeview_templates = builder.get_object ("treeview_templates") as TreeView;
			treeview_objects = builder.get_object ("treeview_objects") as TreeView;
			window.title = "LAview Desktop"
			        + @" $(Config.VERSION_MAJOR).$(Config.VERSION_MINOR).$(Config.VERSION_PATCH)";

			pref_dialog = new PreferencesDialog (application, window);
			subprocess_dialog = new SubprocessDialog (application, window);
			about_dialog = new AboutDialogWindow (application, window);

			fill_liststore_templates ();

			application.app_menu = builder.get_object ("menubar") as MenuModel;
			application.menubar = builder.get_object ("main_toolbar") as MenuModel;
			window.application = application;
		}

		void fill_liststore_templates () {
			var templates = AppCore.core.get_templates_readable_names ();
			liststore_templates.clear();
			Gtk.TreeIter iter = Gtk.TreeIter();
			foreach (var t in templates) {
				liststore_templates.append (out iter);
				liststore_templates.set (iter, 0, t);
			}
		}

		void statusbar_show (string str) {
			var context_id = statusbar.get_context_id ("common_context");
			statusbar.push (context_id, str);
		}

		public void show_all () {
			window.show_all ();
			statusbar_show (_("We're ready, Commander! Select or create a template. :-)"));
		}

		[CCode (instance_pos = -1)]
		public void menu_about_activate (Gtk.ImageMenuItem item) {
			about_dialog.show_all ();
		}

		[CCode (instance_pos = -1)]
		public void action_new_activate (Gtk.Action action) {
			string[] argv = { AppCore.core.lyx_path, "--execute", "buffer-new" };
			try {
				var subprocess = new SubprocessLauncher(  SubprocessFlags.STDIN_PIPE
					                                    | SubprocessFlags.STDOUT_PIPE
					                                    | SubprocessFlags.STDERR_PIPE);
				subprocess.spawnv(argv);
			} catch (Error err) {
				var msg = new MessageDialog (window, DialogFlags.MODAL, MessageType.ERROR,
				                             ButtonsType.CLOSE, _("Error")+@": $(err.message).");
				msg.response.connect ((response_id) => { msg.destroy (); } );
				msg.show ();
			}
		}

		[CCode (instance_pos = -1)]
		public void action_open_activate (Gtk.Action action) {
			FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select templates"), window,
			                                FileChooserAction.OPEN,
			                                _("_Cancel"), ResponseType.CANCEL,
			                                _("_Open"), ResponseType.ACCEPT);
			chooser.select_multiple = true;
			FileFilter filter = new FileFilter ();
			chooser.set_filter (filter);
			filter.add_mime_type ("application/x-tex");
			filter.add_mime_type ("application/x-latex");
			filter.add_mime_type ("application/x-lyx");
			filter.add_pattern ("*.tex");
			filter.add_pattern ("*.latex");
			filter.add_pattern ("*.lyx");

			if (chooser.run () == ResponseType.ACCEPT) {
				var paths = chooser.get_filenames ();

				foreach (unowned string path in paths)
					AppCore.core.add_template (path);

				fill_liststore_templates ();
			}

			chooser.close ();
		}

		void edit_lyx_files (string[] paths) {
			string[] args = { AppCore.core.lyx_path, "--remote" };
			foreach (var p in paths) args += p;
			try {
				var subprocess = new SubprocessLauncher(  SubprocessFlags.STDIN_PIPE
					                                    | SubprocessFlags.STDOUT_PIPE
					                                    | SubprocessFlags.STDERR_PIPE);
				subprocess.spawnv(args);
			} catch (Error err) {
				var msg = new MessageDialog (window, DialogFlags.MODAL, MessageType.ERROR,
				                             ButtonsType.CLOSE, _("Error")+@": $(err.message).");
				msg.response.connect ((response_id) => { msg.destroy (); } );
				msg.show ();
			}
		}

		int[] get_template_indices () {
			var selection = treeview_templates.get_selection ();
			var selected_rows = selection.get_selected_rows (null);
			int[] indices = {};
			foreach (var r in selected_rows) {
				indices += r.get_indices()[0];
			}
			return indices;
		}

		[CCode (instance_pos = -1)]
		public void action_edit_template_activate (Gtk.Action action) {
			edit_selected_templates ();
		}

		[CCode (instance_pos = -1)]
		public void action_delete_activate (Gtk.Action action) {
			var indices = get_template_indices ();
			for (int i = indices.length; i > 0; )
				AppCore.core.remove_template (indices[--i]);
			fill_liststore_templates ();
		}

		int[] get_objects_indices () {
			var selection = treeview_objects.get_selection ();
			var selected_rows = selection.get_selected_rows (null);
			int[] indices = {};
			foreach (var r in selected_rows) {
				indices += r.get_indices()[0];
			}
			return indices;
		}

		[CCode (instance_pos = -1)]
		public void action_compose_activate (Gtk.Action action) {
			var t_indices = get_template_indices ();
			var o_indices = get_objects_indices ();
			if (t_indices.length != 0 && o_indices.length != 0) {
				AppCore.core.compose_object (t_indices[0], o_indices[0]);
			}
			statusbar_show (_("After composing all objects print the document."));
		}

		[CCode (instance_pos = -1)]
		public void action_edit_result_activate (Gtk.Action action) {
			var indices = get_template_indices();
			if (indices.length != 0) {
				var lyx_path = AppCore.core.get_lyx_file_path (indices[0]);
				edit_lyx_files ({ lyx_path });
			}
		}

		void post_print () {
			var indices = get_template_indices();
			var pdf_file = AppCore.core.get_pdf_file_path (indices[0]);
			Utils.open_document (pdf_file, window);
		}

		[CCode (instance_pos = -1)]
		public void action_print_activate (Gtk.Action action) {
			var indices = get_template_indices();
			if (indices.length != 0) {
				try {
					subprocess_dialog.show_all (AppCore.core.print_document (indices[0]),
					                            "=== Print to PDF file... ===\n",
					                            post_print);
				} catch (Error err) {
					var msg = new MessageDialog (window, DialogFlags.MODAL, MessageType.ERROR,
					                             ButtonsType.CLOSE, _("Error")+@": $(err.message).");
					msg.response.connect ((response_id) => { msg.destroy (); } );
					msg.show ();
				}
			}
		}

		[CCode (instance_pos = -1)]
		public void action_preferences_activate (Gtk.Action action) {
			pref_dialog.show_all ();
		}

		[CCode (instance_pos = -1)]
		public void action_ref_activate (Gtk.Action action) {
			try {
				show_uri (null, "https://redmine.backbone.ws/projects/laview/wiki", Gdk.CURRENT_TIME);
			} catch (Error err) {
				var msg = new MessageDialog (window, DialogFlags.MODAL, MessageType.ERROR,
				                             ButtonsType.CLOSE, _("Error")+@": $(err.message).");
				msg.response.connect ((response_id) => { msg.destroy (); } );
				msg.show ();
			}
		}

		void edit_selected_templates () {
			var indices = get_template_indices ();
			if (indices.length != 0) {
				string[] paths = {};
				foreach (var i in indices) {
					paths += AppCore.core.get_template_path_by_index (i);
				}
				edit_lyx_files (paths);
			}
		}

		[CCode (instance_pos = -1)]
		public void templates_row_activated (Gtk.TreeView treeview,
		                                     Gtk.TreePath path,
		                                     Gtk.TreeViewColumn column) {
			edit_selected_templates ();
		}

		[CCode (instance_pos = -1)]
		public void templates_cursor_changed (Gtk.TreeView treeview) {
			var indices = get_template_indices ();
			if (indices.length != 0) {
				var doc_objects = AppCore.core.get_objects_list (indices[0]);
				liststore_doc_objects.clear();
				Gtk.TreeIter iter = Gtk.TreeIter();
				foreach (var t in doc_objects) {
					liststore_doc_objects.append (out iter);
					liststore_doc_objects.set (iter, 0, t);
				}
			}
			statusbar_show (_("Document analized, select an object and set it's properties."));
		}

		[CCode (instance_pos = -1)]
		public void objects_cursor_changed (Gtk.TreeView treeview) {
			statusbar_show (_("Press 'Properties' button to compose the object."));
		}

		[CCode (instance_pos = -1)]
		public void action_saveas_activate (Gtk.Action action) {
			var indices = get_template_indices ();
			if (indices.length == 0) return;
			var tmp_pdf = AppCore.core.get_pdf_file_path (indices[0]);
			if (tmp_pdf == null || tmp_pdf == "") {
				statusbar_show (_("Prepare the document first! >;-]"));
				return;
			}

			FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select destination"), window,
			                                FileChooserAction.SAVE,
			                                _("_Cancel"), ResponseType.CANCEL,
			                                _("_Save"), ResponseType.ACCEPT);
			chooser.select_multiple = false;
			FileFilter filter = new FileFilter ();
			chooser.set_filter (filter);
			filter.add_mime_type ("application/pdf");
			filter.add_pattern ("*.pdf");

			// set folder
			if (AppCore.settings.pdf_save_path != "")
				chooser.set_current_folder(AppCore.settings.pdf_save_path);

			// set current pdf file name or select an existance one
			var template_name = AppCore.core.get_template_path_by_index (indices[0]);
			template_name = File.new_for_path(template_name).get_basename ();
			if (   template_name.down().has_suffix(".lyx")
			    || template_name.down().has_suffix(".tex")
			) {
				var date = Time.local (time_t()).format("-%Y.%m.%d_%H-%M-%S");
				template_name = template_name.splice (template_name.length-4, template_name.length, date+".pdf");
			}
			if (File.new_for_path(template_name).query_exists())
				chooser.set_filename (template_name);
			else
				chooser.set_current_name (template_name);

			// open dialog
			var response = chooser.run ();

			// process response
			if (response == ResponseType.ACCEPT) {
				try {
					File.new_for_path (tmp_pdf).copy (chooser.get_file(), FileCopyFlags.OVERWRITE, null,
					           (current_num_bytes, total_num_bytes) => {
									statusbar_show (@"$current_num_bytes "+_("bytes of")+
					                                @" $total_num_bytes "+_("bytes copied/saved")+".");
					           });
					AppCore.settings.pdf_save_path = chooser.get_file().get_parent().get_path();
					statusbar_show (_("Save/Copy operation complete! :-)"));
				} catch (Error err) {
					var msg = new MessageDialog (chooser, DialogFlags.MODAL, MessageType.ERROR,
					                             ButtonsType.CLOSE, _("Error")+@": $(err.message).");
					msg.response.connect ((response_id) => { msg.destroy (); chooser.close (); } );
					msg.show ();
				}
			}

			chooser.close ();
		}

		[CCode (instance_pos = -1)]
		public void action_quit_activate (Gtk.Action action) {
			window.application.quit();
		}
	}
}
