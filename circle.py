# -*- coding: utf-8 -*-
"""
Created on Thu Jan 26 16:31:32 2023

@author: there
"""
import numpy as np

def circle(center, radius, num_arcs):
    for i in range(num_arcs):
        angle = np.pi / num_arcs * i
        p1 = (int(np.cos(angle) * radius) + center[0], int(np.sin(angle) * radius) + center[1])
        p2 = (int(np.cos(np.pi + angle) * radius) + center[0], int(np.sin(np.pi + angle) * radius) + center[1])
        print(f'{i}:begin x0={p1[0]};y0={p1[1]};x1={p2[0]};y1={p2[1]};end ', end = " ")
        if (i > 0 and i % 4 == 3):
            print()
        
if (__name__ == "__main__"):
    circle((320, 240), 100, 100)