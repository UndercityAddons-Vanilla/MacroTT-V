# Macro Tooltips [MacroTT-V] for Vanilla WoW

Create custom tooltips in macros. MacroTT fills in for the missing *#showtooltip* command that World of Warcraft 1.12 doesn't have.

## Usage

MacroTT provides four slash commands to use in macros.

**/mtts &lt;spell name&gt;**
Displays the tooltip for the spell listed. The name must match exactly. 

**/mtte &lt;equipment slot&gt;**
Displays the tooltip for item currently equipped in the equipment slot. Equipment slot can be one of: *ammo, head, neck, shoulder, body, chest, waist, legs, feet, wrist, hands,  finger, finger1, trinket, trinket2, cloak, mainhand, offhand, ranged, wand, tabard*.

**/mttc &lt;custom header text&gt;**
Displays a tooltip with the custom header text. This is usually followed by additional text (`/mtta`)

**/mtta &lt;additional text&gt;**
Adds the additional text to any of the above tooltips. Multiple `/mtta` lines can be used and blank lines are valid.

Note that ***macro names must be unique***. The addon finds macros by name to read the macro body (*GetActionInfo* wasn't available until patch 2.0.1).

## Compatibility

MacroTT has been tested to work with:
- stock UI bars
- Bongos 
- Discord Action Bars (as of v1.1 - 2018-04-08)

It may work with others. Please let us know.
