
 
(function ($) {
    "use strict";

    $(window).on('load', function(){
        //===== Prealoder
        $('.proloader').delay(500).fadeOut(500)


    });

    $(document).ready(function () {

        //03. Smoot Scroll Effect
        $('#menu li .nav-link, .footer_box ul li a').bind('click', function(event) {
            var $anchor = $(this);
            var headerH = '70';
            $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top - headerH + "px"
            }, 1200, 'easeInSine');
            event.preventDefault();
        });

        //05. sticky header
        function sticky_header(){
            var wind = $(window);
            var sticky = $('header');
            wind.on('scroll', function () {
                var scroll = wind.scrollTop();
                if (scroll < 30) {
                    sticky.removeClass('sticky');
                } else {
                    sticky.addClass('sticky');
                }
            });
        }
        sticky_header();
        //===== Back to top

        // Show or hide the sticky footer button
        $(window).on('scroll', function (event) {
            if ($(this).scrollTop() > 600) {
                $('.back-to-top').fadeIn(200)
            } else {
                $('.back-to-top').fadeOut(200)
            }
        });

        //Animate the scroll to yop
        $('.back-to-top').on('click', function (event) {
            event.preventDefault();

            $('html, body').animate({
                scrollTop: 0,
            }, 1500);
        });

        // Hamburger-menu
        $('.hamburger-menu, #menu li a').on('click', function () {
            $('.hamburger-menu .line-top').toggleClass('current');
            $('.hamburger-menu .line-center').toggleClass('current');
            $('.hamburger-menu .line-bottom').toggleClass('current');
            $('#menu').toggleClass('open');
        });



        //10. Client Slider Initialize
        function client_carouselInit() {
            $('.owl-carousel.client_carousel').owlCarousel({
                loop: true,
                margin: 30,
                items: 5,
                autoplay: true,
                autoplayTimeout: 3000,
                autoplayHoverPause: true,
                smartSpeed: 2000,
                nav: false,
                dots: false,
                responsive: {
                    0: {
                        items: 3
                    },
                    575:{
                        items: 3
                    },
                    768: {
                        items: 4
                    },
                    992: {
                        items: 5
                    }
                }
            });
        }
        client_carouselInit();


        //07. mobile app screenshot
        function mobile_carouselInit() {
            $('.owl-carousel.mobile_active').owlCarousel({
                dots: true,
                loop: true,
                nav: false,
                autoplay: true,
                smartSpeed: 2000,
                autoplayTimeout:3000,
                responsive: {
                    0: {
                        items: 1
                    },
                    375: {
                        items: 2
                    },
                    768: {
                        items: 3
                    },
                    992: {
                        items: 4
                    }
                }
            });
        }
        mobile_carouselInit();


        $('.owl-carousel.testi_slide').owlCarousel({
            loop: true,
            margin: 30,
            items: 1,
            nav: true,
            dots: false,
            navText:['<i class="far fa-long-arrow-left"></i>','<i class="far fa-long-arrow-right"></i>'],
            smartSpeed: 2000,
            autoplayTimeout:3000,
            autoplay: true,
            responsive: {
                576:{
                    items: 1
                },
                768:{
                    items: 1
                },
                992:{
                    items: 1
                },

                1200:{
                    items: 1
                },
            }

        });

        //11. Video Popup Initialize
        //function videoPopupInit() {
        //    $('#play-video').magnificPopup({
        //        type: 'iframe',
        //        iframe: {
        //            patterns: {
        //                youtube: {
        //                  index: 'youtube.com/', 

        //                  id: 'v=',
        //                  src: 'https://www.youtube.com/embed/%id%?autoplay=1'
        //                },
        //            },

        //          srcAction: 'iframe_src',
        //        }
        //    });
        //}
        //videoPopupInit();
    });

})(jQuery);