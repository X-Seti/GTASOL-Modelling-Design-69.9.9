================
 SA Path Tool
================
 Version 0.2a
 2006-10-01
================

Copyright © 2006 by Steve M.

Email: support@steve-m.com
Web: http://www.steve-m.com


DISCLAIMER
~~~~~~~~~~

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

This program is not a public release and must not be distributed!

I am not associated with Rockstar Games, Rockstar North or Take Two in any way.


Usage
~~~~~

1. Exporting paths from 3DSMax

- put PathTool.ms in your \3DSMax*\Scripts\Startup directory
- create a network of paths using linear spline shapes - bezier curves, smooth
  corners and such will be ignored; to create junctions, simply let the spline
  knots overlap (same coordinates!); a junction node can't have more than 15
  branches
- use the "GTA SA Path Tool" panel to define settings for your paths and assign
  them via the "Store" button; if you don't assign settings, the current
  settings will be used as default on exporting
- click the "Generate Paths" button and save them to a file

The created file is a text file and can be edited by hand.


2. Compiling the paths

- simply execute PathTool.exe with the name of the file created in step one as
  first parameter
  Example: PathTool.exe paths.txt
- Nodes0.dat to Nodes63.dat (64 files) will be created in the current work
  directory
- if no or no valid path file is specified, empty node files will be created


3. Using the paths

either
- replace all Nodes*.dat files in SA's gta3.img with the ones created in step 2
or
- create a new img file consisting of the Nodes*.dat files, delete the old
  ones from gta3.img, and link to the new archive in gta.dat



If there are any problems, questions, mistakes, bugs or something else simply
send an email! (support@steve-m.com)

Enjoy

Steve