# Create a module called geometry_calculations that has functions 
# to calculate the area and circumference of a circle.  
# Also, include a rectangle class that has methods for calculating its 
# area and perimeter.  In a separate file called main, import 
# geometry_calculations and execute its capabilities.  

import math

def calculate_area_circle(radius):
    """Calculates the area of a circle given its radius."""
    return math.pi * radius ** 2

def calculate_circumference_circle(radius):
    """Calculates the circumference of a circle given its radius."""
    return 2 * math.pi * radius

class Rectangle:
    """Represents a rectangle with width and height."""

    def __init__(self, width, height):
        self.width = width
        self.height = height

    def calculate_area(self):
        """Calculates the area of the rectangle."""
        return self.width * self.height
    
    def calculate_perimeter(self):
        """Calculates the perimeter of the rectangle."""
        return 2 * (self.width + self.height)
    
    