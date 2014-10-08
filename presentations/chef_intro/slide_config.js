var SLIDE_CONFIG = {
  // Slide settings
  settings: {
    title: 'Blazing Through The Kitchen',
    subtitle: 'intro to opscode chef',
    useBuilds: true, // Default: true. False will turn off slide animation builds.
    usePrettify: true, // Default: true
    enableSlideAreas: true, // Default: true. False turns off the click areas on either slide of the slides.
    enableTouch: true, // Default: true. If touch support should enabled. Note: the device must support touch.
    //analytics: 'UA-XXXXXXXX-1', // TODO: Using this breaks GA for some reason (probably requirejs). Update your tracking code in template.html instead.
    favIcon: 'images/thoughtworks.png',
    fonts: [
      'Open Sans:regular,semibold,italic,italicsemibold',
      'Source Code Pro'
    ],
    //theme: ['mytheme'], // Add your own custom themes or styles in /theme/css. Leave off the .css extension.
  },

  // Author information
  presenters: [{
    name: 'Jinwoo Baek',
    company: '@jinoobaek',
    github: 'http://github.com/kPhilosopher'
  }, {
    name: 'Matt Urbanski',
    company: '@iflowfor8hours',
    www: 'http://www.iflowfor8hours.info',
    github: 'http://github.com/iflowfor8hours'
  }]
};

