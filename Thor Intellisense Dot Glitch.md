<p><strong><span style="font-size:medium">Thor IntellisenseX Dot Glitch</span></strong></p>
<p>It seems inevitable that there be one unavoidable glitch in any new IDE Tool.</p>
<p>The tool <strong>IntellisenseX by Dot</strong> works by using On Key Label to capture any time you press a period (dot). However, there are times when this causes problems (rather than adding features) – when you want the dot to be handled “normally”.</p>
<p>There are at least two reports of difficulties encountered:</p>
<ul>
<li>If you are typing&nbsp; .T. or .F. there is enough of a delay that the second character may be goggled up. This can be remedied by typing slower.
</li><li>If you have a native FoxPro Intellisense dropdown list already and you press a dot, something else goes wrong:</li></ul>
<p>In the example below, native Intellisense has displayed the list of members for Thisform, and after ‘gr’ has been entered, highlights the match to a grid named&nbsp; ‘GrdGrid’.</p>
<p><img title="image" border="0" alt="image" src="Thor%20Intellisense%20Dot%20Glitch_image_2.png" width="503" height="279" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<p>The normal behavior for Intellisense is that when you now enter a period (dot), the entire name ‘GrdGrid’ is entered into your code window followed by the dot. We have done this so often that it is reflexive behavior.</p>
<p>However, if <strong>IntellisenseX by Dot</strong> is active, pressing the dot here does NOT work as expected. The remainder of the word is not entered into your code window. Instead, you get this:</p>
<p><img title="image" border="0" alt="image" src="Thor%20Intellisense%20Dot%20Glitch_image_4.png" width="503" height="69" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<p>There are at least three different ways to get around this problem:</p>
<ul>
<li>Instead of pressing dot, press space &#43; backspace &#43; dot </li><li>Assign a hot key to <strong>IntellisenseX by Dot</strong> (which toggles it) so that you can turn it off before you press the dot, then press it again afterwards to re-active
<strong>IntellisenseX by Dot.</strong> </li><li>Use <strong>IntellisenseX by Hot Key</strong> instead, which does not have this issue.</li></ul>
<p><strong>Recommendation</strong>: As annoying as this behavior may be from time to time, so much so that you may want to stop using<strong> Intel … by Dot
</strong>and begin using&nbsp; <strong>Intel … by Hot Key </strong>instead, we recommend sticking with
<strong>Intel … by Dot </strong>until you have become completely familiar with all the features automatically provided by it. Using
<strong>Intel… by Hot Key, </strong>after all, requires that you know when you can invoke IntellisenseX.</p>
