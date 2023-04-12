# SH4RE-ECE496

Demo Video: https://www.youtube.com/watch?v=YMjhxEgZy-A&ab_channel=WasifButt

As part of our final year design project course ECE496, we developed SH4RE, a peer-to-peer rental iOS app that aims to simplify and streamline the rental process for users. Online applications that facilitate peer-to-peer buy/sell services, more generally referred to as classifieds, have been available for a while - however, they all focus on buying and selling. We want to fill the demand void and give users within Toronto an intuitive and straightforward way to rent household items within their local area. 

The app has 4 key general functionalities:
1. Rental requests (messaging and reviewing)
2. Viewing listings (searching, map interface, viewing page)
3. Account management (create account, favourties, my listings)
4. Managing listings (create edit, delete, promote listings)
Here is a general architectural diagram of our software: 



## Developer Environment
Required Tools:
- Xcode 14.1 (Link [here](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_14.1/Xcode_14.1.xip), requires Apple ID login)
    - requires MacOS 12.5+
- HomeBrew (or equivalent package manager)
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
- GitHub CLI
    - `brew install gh`
    - Once installed, login to your github account using `gh auth login` and following the prompts. Note: it is easiest to login using HTTPS via a web browser.
- All image icon assets are already downloaded as part of Xcode, to view the full list of these assets you have to download Apple's MacOS app [here](https://developer.apple.com/sf-symbols/). 
