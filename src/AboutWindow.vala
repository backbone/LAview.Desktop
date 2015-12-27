namespace LAview.Desktop {

	using Gtk;

	/**
	 * About dialog.
	 */
	public class AboutDialogWindow {
		AboutDialog dialog;

		public AboutDialogWindow (Window parent) throws Error {
			var builder = new Builder ();
			builder.add_from_file (AppDirs.ui_dir + "/laview-desktop.glade");
			builder.connect_signals (this);

			dialog = builder.get_object ("aboutdialog_window") as AboutDialog;
			dialog.set_destroy_with_parent (true);
			dialog.set_transient_for (parent);
			dialog.set_modal (true);
			dialog.delete_event.connect ((source) => {return true;});

			dialog.version = @" $(Config.VERSION_MAJOR).$(Config.VERSION_MINOR).$(Config.VERSION_PATCH)";

			dialog.response.connect ((response_id) => {
				if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
					dialog.hide_on_delete ();
				}
			});

			dialog.logo = new Gdk.Pixbuf.from_resource_at_scale ("/ws/backbone/laview/desktop/about.svg", 256, 256, true);
		}

		public void show_all () {
			dialog.show_all ();
		}
	}
}
