# Add banner component for demo notice
_Exported on 8/30/2025 at 22:34:45 PDT from Cursor (1.5.7)_

---

**User**

Add a "banner" component to the layout, at the very top of the page, that says that "This website is for demo purposes only. No information on this website will be sent to any government agency."

---

**Cursor**

I'll help you add a banner component to the layout. First, let me examine the current layout structure to understand where to place the banner.


Now I'll add a banner component at the very top of the page, right after the opening `<body>` tag and before the existing header. I'll use USWDS styling to make it consistent with the rest of the application.


```ruby
  <body>
    <div class="usa-app">
      <header class="usa-header usa-header--basic">

->

  <body>
    <div class="usa-app">
      <div class="usa-banner">
        <div class="usa-accordion">
          <header class="usa-banner__header">
            <div class="usa-banner__inner">
              <div class="grid-col-auto">
                <img class="usa-banner__header-flag" src="https://cdn.jsdelivr.net/npm/@uswds/uswds@3.7.0/dist/img/us_flag_small.png" alt="U.S. flag">
              </div>
              <div class="grid-col-fill tablet:grid-col-auto">
                <p class="usa-banner__header-text">This website is for demo purposes only. No information on this website will be sent to any government agency.</p>
              </div>
            </div>
          </header>
        </div>
      </div>
      <header class="usa-header usa-header--basic">
```

Perfect! I've added a banner component at the very top of the page using the US Web Design System's banner component. The banner includes:

1. A U.S. flag icon for visual consistency with government websites
2. The demo disclaimer text you requested
3. Proper USWDS styling and responsive grid layout
4. Placement at the very top of the page, before the main header

The banner will now appear on all pages of your application since it's in the main layout file. It uses the standard USWDS banner styling which will be consistent with the rest of your government-style interface.

