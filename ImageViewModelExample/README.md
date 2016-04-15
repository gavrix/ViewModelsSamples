# ImageViewModelModel example

This is an example project using [ImageViewModel](https://github.com/gavrix/ImageViewModel/)

## Description

Example project uses GitHub API to fetch and show list of users including their username and avatar image.
Avatar images are managed by `ImageViewModel`.

## Design

App consists of main screen `ViewController` + `UsersListViewModel` showing the list of users via UITableView.

Each cell inside UITableView is represented by `UserTableViewCell` + `UserItemViewModel`. `UserItemViewModel` has one formal input which is the user model object via `user` property represented by RAC's `MutableProperty` and two formal outputs: the `username` property represented by RAC's `AnyProperty` and userpic's image viewModel, represented by `ImageViewModel`.

In order for `ImageViewModel` to work we bind it's properties `image` to signal derived from current `user` transformed to extracted avatar's url, as well as  `UITableViewCell` updates it's `imageViewSize` property with the size of `UIImageView`'s size inside the `layoutSubviews` method (thus guaranteed thath `ImageViewModel` is resizing image to correct size).

With that basic setup ready, we only have to set `user` property of the `UserItemViewModel` to User model object, and `ImageViewModel` will do the rest to download, cache and resize user's avatar.

As a bonus, we observe `imageTransitionSignal` signal provided by `ImageViewModel` to add fade transition when resized image is delivered by the `ImageViewModel` asynchronously. 


Data is requested from [users](https://api.github.com/users) GitHub's API.

