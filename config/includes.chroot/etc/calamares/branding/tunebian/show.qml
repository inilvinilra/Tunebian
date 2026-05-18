import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Slide {
        Image {
            id: welcome
            source: "tunebian-welcome.svg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
        }
    }
}
