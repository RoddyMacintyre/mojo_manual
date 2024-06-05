#!python
import tkinter as tk

class App:
    def __init__(self):
        self._root = tk.Tk()
        self.clicked = False
    
    def click(self):
        self.clicked = True
    
    def create_button(self, button_text: str):
        button = tk.Button(self._root, 
                           text=button_text, 
                           command=self.click)
        button.place(relx=0.5, rely=0.5, anchor=tk.CENTER)

    def create(self, res: str):
        self._root.geometry(res)
        self.create_button("Hello Mojo!")
    
    def update(self):
        self._root.update()