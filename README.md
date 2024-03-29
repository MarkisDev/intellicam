# What is this?
Hey! This is my implemention of an intelligent camera that can detect objects and automatically zoom to the selected object!

It was built as a qualification task challenge for [https://ccextractor.org/](https://ccextractor.org/)

# How does this work?

This application uses `google_mlkit_object_detection` with a custom trained model to detect objects. When it detects an object, it draws a rectangle around it (bounding box) using `CustomPainter`.

When you touch the rectangle, it will automatically zoom to fit the object!

The application also allows you to reset zoom, take a picture (saves to your gallery) and pause/play the camera preview!

# Video (GIF)

![video.gif](https://github.com/MarkisDev/intellicam/blob/main/screenshots/video.gif)

# Screenshots 

![objects.jpg](https://github.com/MarkisDev/intellicam/blob/main/screenshots/1.jpg)
![objects.jpg](https://github.com/MarkisDev/intellicam/blob/main/screenshots/2.jpg)
![objects.jpg](https://github.com/MarkisDev/intellicam/blob/main/screenshots/3.jpg)
![objects.jpg](https://github.com/MarkisDev/intellicam/blob/main/screenshots/4.jpg)



# Apk file?
You can find the first pre-release [here!](https://github.com/MarkisDev/caninecam/releases/tag/release)
