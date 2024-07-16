var $ = jQuery.noConflict();
$(document).ready(
   (function () {
      $('.slider-wrap').slick({
         dots: false,
         infinite: true,
         speed: 100,
         autoplay: true,
         fade: true,
         arrows: false,
         cssEase: 'linear'
      });
      $('.category-wrap').slick({
         dots: false,
         slidesToShow: 6,
         slidesToScroll: 1,
         infinite: true,
         speed: 100,
         autoplay: true,
         arrows: false,
         responsive: [
            {
               breakpoint: 1100,
               settings: {
                  slidesToShow: 5
               }
            },
            {
               breakpoint: 1024,
               settings: {
                  slidesToShow: 4
               }
            },
            {
               breakpoint: 699,
               settings: {
                  slidesToShow: 3
               }
            },
            {
               breakpoint: 599,
               settings: {
                  slidesToShow: 2
               }
            },
            {
               breakpoint: 399,
               settings: {
                  slidesToShow: 1
               }
            }
         ]
      });
   })
)