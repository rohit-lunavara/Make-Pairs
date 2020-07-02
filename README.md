# Make-Pairs

An iOS game where you find pairs from a group of 16 cards.

A memory based card game based on the popular game show "Concentration".

Support for all iOS devices (13.0+) using AutoLayout (includes UI resize based on iOS device size classes) and macOS (10.15+) using Mac Catalyst.

# Technologies and Frameworks Used

- **UserDefaults** to store the game session when the app is terminated.
- **Key-Value Observing** to handle loading and saving the game session.
- **Grand Central Dispatch** to synchronize user interaction.
- **Core Graphics** to customize **UIButton** by adding custom styling and shadows.
- Extending **UIButton** to group related actions and add animations.

# Screenshots

## Start
![Start](https://github.com/rohit-lunavara/Make-Pairs/blob/master/Device%20Mockups/Start_iphone.png?raw=true)

## Gameplay
![Gameplay](https://github.com/rohit-lunavara/Make-Pairs/blob/master/Device%20Mockups/Gameplay_iphone.png?raw=true)

## Reset
![Reset](https://github.com/rohit-lunavara/Make-Pairs/blob/master/Device%20Mockups/Reset_iphone.png?raw=true)

## End
![End](https://github.com/rohit-lunavara/Make-Pairs/blob/master/Device%20Mockups/End_iphone.png?raw=true)

## Share
![Share](https://github.com/rohit-lunavara/Make-Pairs/blob/master/Device%20Mockups/Share_iphone.png?raw=true)

# Future Scope

- Change **UIButton** to **UICollectionView** to allow variable number of cells.
- Add game variations to pair images as well.
- Add separate Easy, Medium and Hard modes.
- Add a timed mode.
