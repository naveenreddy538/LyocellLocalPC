<%@ include file="/init.jsp" %>

<!DOCTYPE html>
<html>
<head>
<title>Directory Upload Example</title>
<style type="text/css">
* {
	box-sizing: border-box;
}

body {
	font-family: Arial;
	padding: 40px;
	margin: 0;
}

h1 {
	margin-top: 0;
}

h1, h2 {
	color: #0576A1;
}

a {
	text-decoration: none;
	color: #0074D9;
}

a:hover {
	color: #42A1F5;
}

#dropDiv {
	width: 100%;
	border: 1px solid #CCCCCC;
	margin-top: 20px;
	padding: 80px 20px;
	text-align: center;
	color: #CCCCCC;
}

#dropDiv.over {
	border-color: #DE7E7E;
	color: #DE7E7E;
	background-color: #FFEDED;
}

pre.code {
	background-color: #F9F9F9;
	padding: 10px;
	display: block;
	display: none;
	border: 1px solid #EBEBEB;
}

#console {
	border: 1px solid #EBEBEB;
	background-color: #F9F9F9;
	color: #333333;
	padding: 10px;
}
</style>
</head>

<body>

<h1>Directory Upload Demo</h1>
<p>To enable directory upload, certain new APIs are needed which are outlined in the <a href="proposal.html">directory upload spec proposal</a>. There are two ways we can upload files and directories: a file input with the &quot;directory&quot; attribute, or an element with a drop event listener. Below are examples of these methods in action using the new APIs (the polyfill only works in Chrome).</p>

<h2>1. File Input</h2>
<input type="file" id="fileInput" allowdirs multiple />
<div>
<h4><a href="#" onclick="return toggleDisplay('code-fileinput');">Code Example</a></h4>
<pre class="code" id="code-fileinput">
&lt;input type="file" id="fileInput" allowdirs multiple />

&lt;script type="text/javascript">
document.addEventListener('DOMContentLoaded', function(event) {
	document.getElementById('fileInput').addEventListener('change', function() {
		var uploadFile = function(file, path) {
			console.log(path, file);
			// handle file uploading
		};

		var iterateFilesAndDirs = function(filesAndDirs, path) {
			for (var i = 0; i < filesAndDirs.length; i++) {
				if (typeof filesAndDirs[i].getFilesAndDirectories === 'function') {
					var path = filesAndDirs[i].path;

					// this recursion enables deep traversal of directories
					filesAndDirs[i].getFilesAndDirectories().then(function(subFilesAndDirs) {
						// iterate through files and directories in sub-directory
						iterateFilesAndDirs(subFilesAndDirs, path);
					});
				} else {
					uploadFile(filesAndDirs[i], path);
				}
			}
		};

		// begin by traversing the chosen files and directories
		if ('getFilesAndDirectories' in this) {
			this.getFilesAndDirectories().then(function(filesAndDirs) {
				iterateFilesAndDirs(filesAndDirs, '/');
			});
		}
	});
});
&lt;/script>
</pre>
</div>

<h2>2. Drag &amp; Drop</h2>
<div id="dropDiv">Drag &amp; drop your files here!</div>
<div>
<h4><a href="#" onclick="return toggleDisplay('code-draganddrop');">Code Example</a></h4>
<pre class="code" id="code-draganddrop">
&lt;div id="dropDiv">Drag &amp; drop your files here!&lt;/div>

&lt;script type="text/javascript">
document.addEventListener('DOMContentLoaded', function(event) {
	document.getElementById('dropDiv').addEventListener('drop', function (e) {
		e.stopPropagation();
		e.preventDefault();

		var uploadFile = function(file, path) {
			console.log(path, file);
			// handle file uploading
		};

		var iterateFilesAndDirs = function(filesAndDirs, path) {
			for (var i = 0; i < filesAndDirs.length; i++) {
				if (typeof filesAndDirs[i].getFilesAndDirectories === 'function') {
					var path = filesAndDirs[i].path;

					// this recursion enables deep traversal of directories
					filesAndDirs[i].getFilesAndDirectories().then(function(subFilesAndDirs) {
						// iterate through files and directories in sub-directory
						iterateFilesAndDirs(subFilesAndDirs, path);
					});
				} else {
					uploadFile(filesAndDirs[i], path);
				}
			}
		};

		// begin by traversing the chosen files and directories
		if ('getFilesAndDirectories' in e.dataTransfer) {
			e.dataTransfer.getFilesAndDirectories().then(function(filesAndDirs) {
				iterateFilesAndDirs(filesAndDirs, '/');
			});
		}
	});
});
&lt;/script>
</pre>
</div>

<h3>Output</h3>
<pre id="console"></pre>

<script type="text/javascript" src="polyfill.js"></script>
<script type="text/javascript">
function toggleDisplay(id) {
	var el = document.getElementById(id);

	el.style.display = el.style.display === 'block' ? 'none' : 'block';

	return false;
}

document.addEventListener('DOMContentLoaded', function(event) {
	function clearCons() {
		var cons = document.getElementById('console');
		if ('directory' in document.getElementById('fileInput')) {
			cons.innerHTML = 'Use one of the above methods to show files here...';
		} else {
			cons.innerHTML = 'Directory upload is not supported. If using the polyfill, it is only supported in Chrome 25+.';
		}
	}

	clearCons();

	function printToScreen() {
		var cons = document.getElementById('console');

		cons.innerHTML += '<br>';

		for (var i = 0; i < arguments.length; i++) {
			var arg = arguments[i];

			cons.innerHTML += '<br>';

			if (arg.constructor === File) {
				arg = 'file name: ' + arg.name + '; type: ' + arg.type;
			}

			cons.innerHTML += arg;
		}
	}

	/** File Input **/
	document.getElementById('fileInput').addEventListener('change', function() {
		clearCons();

		var uploadFile = function(file, path) {
			printToScreen(path, file);
			// handle file uploading
		};

		var iterateFilesAndDirs = function(filesAndDirs, path) {
			for (var i = 0; i < filesAndDirs.length; i++) {
				if (typeof filesAndDirs[i].getFilesAndDirectories === 'function') {
					var path = filesAndDirs[i].path;

					// this recursion enables deep traversal of directories
					filesAndDirs[i].getFilesAndDirectories().then(function(subFilesAndDirs) {
						// iterate through files and directories in sub-directory
						iterateFilesAndDirs(subFilesAndDirs, path);
					});
				} else {
					uploadFile(filesAndDirs[i], path);
				}
			}
		};

		// begin by traversing the chosen files and directories
		if ('getFilesAndDirectories' in this) {
			this.getFilesAndDirectories().then(function(filesAndDirs) {
				iterateFilesAndDirs(filesAndDirs, '/');
			});
		}
	});

	/** Drag and Drop **/
	function dragHover(e) {
		e.stopPropagation();
		e.preventDefault();

		if (e.type === 'dragover') {
			e.target.className = 'over';
		} else {
			e.target.className = '';
		}
	}

	document.getElementById('dropDiv').addEventListener('dragover', dragHover);
	document.getElementById('dropDiv').addEventListener('dragleave', dragHover);

	document.getElementById('dropDiv').addEventListener('drop', function (e) {
		e.stopPropagation();
		e.preventDefault();

		clearCons();

		e.target.className = '';

		var uploadFile = function(file, path) {
			printToScreen(path, file);
			// handle file uploading
		};

		var iterateFilesAndDirs = function(filesAndDirs, path) {
			for (var i = 0; i < filesAndDirs.length; i++) {
				if (typeof filesAndDirs[i].getFilesAndDirectories === 'function') {
					var path = filesAndDirs[i].path;

					// this recursion enables deep traversal of directories
					filesAndDirs[i].getFilesAndDirectories().then(function(subFilesAndDirs) {
						// iterate through files and directories in sub-directory
						iterateFilesAndDirs(subFilesAndDirs, path);
					});
				} else {
					uploadFile(filesAndDirs[i], path);
				}
			}
		};

		// begin by traversing the chosen files and directories
		if ('getFilesAndDirectories' in e.dataTransfer) {
			e.dataTransfer.getFilesAndDirectories().then(function(filesAndDirs) {
				iterateFilesAndDirs(filesAndDirs, '/');
			});
		}
	});
});
</script>
</body>
</html>
