/*
 * From
 * http://blog.romeda.org/2010/06/beautiful-lines.html
 */

var setTextMeasure = function (contentElement, targetMeasure, maxSize, minSize) {

  if (!contentElement) contentElement = document.createElement('p');
  if (!targetMeasure) targetMeasure = 66;
  if (!maxSize) maxSize = 16;
  if (!minSize) minSize = 9;

  var sizer = contentElement.cloneNode();

  sizer.style.cssText = 'margin: 0; padding: 0; color: transparent; background-color: transparent; position: absolute;';

  var letters = 'aaaaaaaabbcccddddeeeeeeeeeeeeeffgghhhhhhiiiiiiijkllllmmnnnnnnnooooooooppqrrrrrrsssssstttttttttuuuvwxyyz';
  sizer.textContent = letters;

  document.body.appendChild(sizer);
  var characterWidth = sizer.offsetWidth / letters.length;
  document.body.removeChild(sizer);

  var contentWidth = contentElement.offsetWidth;
  
  var measuredFontSize = parseFloat(
                           document.defaultView.
                                    getComputedStyle(document.body, null).
                                    getPropertyValue('font-size').
                                    replace('px', '') );

  var actualMeasure = contentWidth / characterWidth;
  var newMeasure = measuredFontSize * actualMeasure / targetMeasure;

  if (newMeasure > maxSize) newMeasure = maxSize;
  if (newMeasure < minSize) newMeasure = minSize;

  document.body.style.fontSize = newMeasure + "px";
}

