# Trading Simulator

Trading simulator is a free, open source application to help you learn to practice technical analysis of financial markets.

Trading simulator embeds a database of 155 stocks with a daily quotation history between 31-12-2011 and 05-03-2021.


## Installation

### Prerequisites 

-  MacOs 11.x 

### Option 1: Binary

Download the latest binary from the [Releases page](https://github.com/machille/TradingSimulator/releases/download/v1.0/TradingSimulator.dmg). It's the easiest way to get started with Trading Simulator.

### Option 2: From source

Requirements:
- Xcode 12.x installed in your computer.

Open TradingSimulator.xcodeproj in Xcode and hit run. This method will build everything and run the app.


## Usage

![Start Panel](screenshot/TradingSimulatorStart.png?raw=true "Start Panel")

Firstly, select a stock and click on the Start button to start a new simulation or on the Continue button to resume an existing simulation or on the Clear button to clear an existing one. 


![Simulation Panel](screenshot/TradingSimulatorMain.png?raw=true "Simulation Panel")

There are 2 major areas in the Simulation panel: on the left the Simulation Position area and on the right the Chart area. 

The Simulation Position is where you’ll see the global position, the actual position, the trading journal. The (i) button provides you a performance summary that includes a variety of performance metrics.

Within the Simulation Position area, you can also open a new position or close a position. With the Next button you will increment the chart with one day and calculate the profit and loss of your position and check the stop loss.  

The Chart area consists of two charts with tabs on the top: stock chart with arrows for buy and sell positions and index chart for market trend. Each chart consists of five charts model with tabs on the right, for example WEEK1 will show you a weekly chart.


![Order Panel](screenshot/TradingSimulatorPosition.png?raw=true "Order Panel") 

Open / Close trade panel let you choose the quantity and the stop loss with a comment for any trading decision. 
 

![Result Panel](screenshot/TradingSimulatorResult.png?raw=true "Result Panel") 

Click on (i) button to view your performance summary.


## Preferences

![Preferences Panel](screenshot/TradingSimulatorPref.png?raw=true "Preferences Panel") 

The preferences panel let you update the default value for start balance, starting date, market index and show an arrow flag for buy and sell arrow in stock chart.

Licence
Trading Simulator is provided under the MIT License.

```text
MIT License
Copyright (c) 2021 Maroun Achille

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR PLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,PARTICULAR PURPOSE 
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
OR OTHER DEALINGS IN THE SOFTWARE.
```

Made in France by Maroun Achille 
