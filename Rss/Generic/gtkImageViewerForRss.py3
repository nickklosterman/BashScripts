#!/usr/bin/python 

#https://python-gtk-3-tutorial.readthedocs.org/en/latest/index.html
#http://askubuntu.com/questions/165276/load-and-show-an-image-from-the-web-in-python-with-gtk-3
#http://askubuntu.com/questions/132038/key-is-pressed-in-gi-repository-gdk?rq=1
import os
import glob
from gi.repository import Gtk
from gi.repository.GdkPixbuf import Pixbuf 

class ImageViewer:
    def __init__(self,globber):
#        self.files=glob.glob('/home/arch-nicky/Art/*.jpg') #this globs the file and includes the full path.
        self.files=glob.glob('/home/arch-nicky/Git/PhotoPrintPrep/*.jpg') #this globs the file and includes the full path.
#        self.files=glob.glob(globber) #this globs the file and includes the full path.
#        for image in files:
#            print(image)
        self.filelistlength=len(self.files)
        if self.filelistlength>0:
            self.imgname=self.files[0]
        else:
            self.imgname=""
        print("opening %s" % self.imgname)
        
        self.fileindex=0


        self.image=Gtk.Image()
        self.pb = Pixbuf.new_from_file(self.imgname)
        self.image.set_from_pixbuf(self.pb)
        
        self.win=Gtk.Window()
        self.win.connect("key-release-event",self.on_key_press_event)
        self.win.connect("delete-event",Gtk.main_quit)
        self.win.add(self.image)
        self.win.show_all()
        Gtk.main()

    def refresh_image(self):
        self.pb = Pixbuf.new_from_file(self.imgname)
        self.image.set_from_pixbuf(self.pb)
        
    def on_key_press_event(self, widget, event):
            """ Check if any of the key in the shortcut ctrl-alt-u is released """
        # ctrl = 65507, alt = 65513, u = 117, v = 118
            keysForward = [65507,118 ]
            keysBackward = [65513,117]
            if event.keyval in keysForward:
                self.fileindex=self.fileindex+1
                if self.fileindex > self.filelistlength-1:
                    self.fileindex=0 #loop back around if we try to index past the end of the array
                self.imgname=self.files[self.fileindex]
                print("selected image: %s" % self.imgname)

            if event.keyval in keysBackward:
                self.fileindex=self.fileindex-1
                if self.fileindex <0:
                    self.fileindex=self.filelistlength-1 #loop back around if we try to index past the end of the array
                self.imgname=self.files[self.fileindex]
                print("selected image: %s" % self.imgname)
            self.refresh_image()


bob=ImageViewer('/home/arch-nicky/Art/*.jpg')


#parse feed file, create temp directory in /tmp/ to download the images, try to download image, except when disk space low, cycle through displaying images, delete tmp folder when exit app, display URL of image / allow for option to save image off to the .RSS directory or something. 
