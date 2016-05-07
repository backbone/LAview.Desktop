namespace LAview.Desktop {

	using Gtk;

	/**
	 * Subprocess window.
	 */
	public class SubprocessDialog {
		Dialog dialog;
		ScrolledWindow scrolled_window;
		TextView textview_stderrout;
		Subprocess sp;
		unowned PostProcessDelegate ppdelegate;

		public delegate void PostProcessDelegate ();

		public SubprocessDialog (Gtk.Application application, Window parent) throws Error {
			var builder = new Builder ();
			builder.add_from_file (AppDirs.ui_dir + "/laview-desktop.glade");
			builder.connect_signals (this);

			dialog = builder.get_object ("subprocess_dialog") as Dialog;
			dialog.transient_for = parent;
			dialog.modal = true;
			//dialog.application = application;
			dialog.delete_event.connect ((source) => {return true;});
			textview_stderrout = builder.get_object ("textview_stderrout") as TextView;
			scrolled_window = builder.get_object ("subprocess_scroll") as ScrolledWindow;
		}

		void scroll_down () {
			var vadjustment = scrolled_window.get_vadjustment ();
			vadjustment.value = vadjustment.upper;
			scrolled_window.set_vadjustment (vadjustment);
		}

		async void subprocess_async () {
			try {
				var ds_out = new DataInputStream(sp.get_stdout_pipe());
				try {
					for (string s = yield ds_out.read_line_async(); s != null; s = yield ds_out.read_line_async()) {
						textview_stderrout.buffer.text += s + "\n";
						scroll_down ();
					}
				} catch (IOError err) {
					assert_not_reached();
				}
				if ((sp.wait_check()) == false) throw new IOError.FAILED(_("Error running subprocess."));
				ppdelegate ();
				dialog.hide ();

			} catch (Error err) {
				textview_stderrout.buffer.text += _("Error: ")+err.message;
				scroll_down ();
				if (sp != null) {
					var ds_err = new DataInputStream(sp.get_stderr_pipe());
					try {
						for (string s = yield ds_err.read_line_async(); s != null; s = yield ds_err.read_line_async()) {
							textview_stderrout.buffer.text += s + "\n";
							scroll_down ();
						}
					} catch (IOError err) {
						assert_not_reached();
					}
				}
			}
		}

		public void show_all (Subprocess sp, string message, PostProcessDelegate ppdelegate) {
			this.sp = sp;
			textview_stderrout.buffer.text = message;
			this.ppdelegate = ppdelegate;
			dialog.show_all ();
			subprocess_async.begin ();
		}

		[CCode (instance_pos = -1)]
		public void button_stop_clicked (Button button) {
			sp.force_exit ();
			dialog.hide ();
		}
	}
}
