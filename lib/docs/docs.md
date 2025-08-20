### Screens (Routes)
1. `/`: Splash screen => The app must go through this screen when opens, no matter what the initial route or the requested screen is. This is done by checking the status of a flag `initialized` defined in `SettingsState`. When the status of that flag is `false`, the app must redirect to this screen. After that, this screen decides whether the app is permitted to go to the requested screen or not. All redirect logics are handled here.
2. `/onboarding`: Intro or onboarding screen. Generally consists of three / four pages that showcases what the app can do. If the app is opened for the first time, then this screen must be displayed after the splash screen.
3. 









3. *Dashboard*
4. *Settings*
5. *Transactions*
   1. *Add transaction*

## Information about the router
Best practice for uri design is that path-params are used to identify a specific resource or resources, while query-parameters are used to sort/filter those resources.

1. 
2
3. `/edit_profile` => Edit profile screen. If no profiles exist, redirect to this page.
4. `/transactions` => Home screen 🏠 consists of four bottom navigation items. These pages (or screens) are arranged in `IndexedStack`, so that their states can be preserved. While accessing `/transactions?tab=null`, first navigation 🧭 item will be displayed by default.
   1. `/transactions?type=mutualfund` => Dashboard screen, also redirects from `/dashboard`
   2. `/transactions?type=stock` => Insight screen, also redirects from `/insight`
   3. `/transactions?type=nsc` => Chart screen, also redirects from `/chart`
   4. `/transactions?type=gold` => Settings screen, also redirects from `/settings`. One can access `/settings/[some_route]`, but when they tries to access `/settings`, it redirects to `/transactions?tab=settings`.
5. `/categories` => Listing all available categories
6. `/add_transaction` => Add new transaction

### Database
Hive database / boxes:
1. `user` box: contains information about the user, like `userName`, `currency`, `categories` (`CategoryModel`) etc.
2. `preferences` box: contains information about the app, like `onboardingCompleted`, `darkTheme`, `locale`, etc.


### Naming conventions
1. components, widgets (collection of components and widgets) => prefixed with 'EM'
2. services => ends with 'Service'
3. screens => ends with 'Screen'


