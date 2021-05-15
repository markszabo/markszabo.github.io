document.addEventListener("DOMContentLoaded", function() {
  var elements = document.querySelectorAll('img[src$="#lb"]');
  elements.forEach(image => {
    //image.classList.add("autogallery-img");
    var parent = image.parentElement;
    parent.classList.add("inline-image-parent");
    var url = image.getAttribute('src');
    var alt = image.getAttribute('alt');
    var a = document.createElement("a");
    a.href = url;
    parent.replaceChild(a, image);
    a.appendChild(image);
    if(alt){
      var p = document.createElement("p");
      p.innerText = alt;
      p.classList.add("text-after-img");
      parent.appendChild(p);
    }
  });
});
