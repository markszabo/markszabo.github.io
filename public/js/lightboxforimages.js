document.addEventListener("DOMContentLoaded", function() {
  var elements = document.querySelectorAll('img[src$="#lb"]');
  elements.forEach(element => {
    var image = element;
    image.class = "autogallery-img";
    var url = element.getAttribute('src');
    var a = document.createElement("a");
    a.href = url;
    element.parentElement.replaceChild(a, element);
    a.appendChild(image);
  });
});
