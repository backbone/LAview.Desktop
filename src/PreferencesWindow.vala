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
		FileChooserButton filechooserbutton_pdflatex;

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
			liststore_objects = builder.get_object ("liststore_objects") as Gtk.ListStore;
			filechooserbutton_lyx = builder.get_object ("filechooserbutton_lyx") as FileChooserButton;
			filechooserbutton_pdflatex = builder.get_object ("filechooserbutton_pdflatex") as FileChooserButton;

			fill_liststore_data ();
			fill_liststore_objects ();

			filechooserbutton_lyx.set_filename (AppCore.core.lyx_path);
			filechooserbutton_pdflatex.set_filename (AppCore.core.pdflatex_path);
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
		public void pdflatex_file_set (FileChooserButton chooser) {
			AppCore.core.pdflatex_path = chooser.get_filename ();
		}
	}
}
