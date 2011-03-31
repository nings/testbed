//XML stuff
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import java.io.StringReader;

// File stuff
import java.io.*;

// ArrayList...:
import java.util.*;

// Threading:
import java.lang.Thread;
import java.lang.Runnable;

// GUI stuff:
import javax.swing.*;
import java.awt.*;

public class scenariorunner3 implements Runnable {
	
	private static class action {
		public long timestamp;
		public String cmd;

		public action(long timestamp, String cmd) {
			this.timestamp = timestamp;
			this.cmd = cmd;
		}
	}

	private static class actionComparator implements Comparator<action> {
		public final int compare(action a, action b) {
			return (int) (a.timestamp - b.timestamp);
		}
	}

	private static class linkTuple {
		public int firstNode;
		public int secondNode;
		public int startTime;
		public int stopTime;

		public linkTuple(int _firstNode, int _secondNode, int _startTime,
				int _stopTime) {
			firstNode = _firstNode;
			secondNode = _secondNode;
			startTime = _startTime;
			stopTime = _stopTime;
		}
	}

	static linkTuple[] parseLinkTuples(String[] trace) {
		linkTuple[] tmp, retval;
		int i, j;

		tmp = new linkTuple[trace.length];
		j = 0;
		for (i = 0; i < trace.length; i++) {
			String[] brokenDown = trace[i].split("\\s+");
			if (brokenDown.length >= 4) {
				tmp[j] = new linkTuple(Integer.parseInt(brokenDown[0]),
						Integer.parseInt(brokenDown[1]),
						Integer.parseInt(brokenDown[2]),
						Integer.parseInt(brokenDown[3]));
				j++;
			}
		}

		if (j != trace.length) {
			retval = new linkTuple[j];
			for (i = 0; i < j; i++)
				retval[i] = tmp[i];
		} else
			retval = tmp;
		return retval;
	}

	static linkTuple[] preprocess(linkTuple[] tuple) {
		
		if (tuple.length == 0)
			return tuple;

		int i, j, a, b, minNode, maxNode;
		int minTime, maxTime, startTime, stopTime;
		int[] connectivityMap;
		ArrayList<linkTuple> retval = new ArrayList<linkTuple>();

		minTime = tuple[0].startTime;
		maxTime = tuple[0].startTime;
		minNode = tuple[0].firstNode;
		maxNode = tuple[0].firstNode;

		for (i = 0; i < tuple.length; i++) {
			if (minTime > tuple[i].startTime)
				minTime = tuple[i].startTime;
			if (minTime > tuple[i].stopTime)
				minTime = tuple[i].stopTime;
			if (maxTime < tuple[i].startTime)
				maxTime = tuple[i].startTime;
			if (maxTime < tuple[i].stopTime)
				maxTime = tuple[i].stopTime;

			if (minNode > tuple[i].firstNode)
				minNode = tuple[i].firstNode;
			if (minNode > tuple[i].secondNode)
				minNode = tuple[i].secondNode;
			if (maxNode < tuple[i].firstNode)
				maxNode = tuple[i].firstNode;
			if (maxNode < tuple[i].secondNode)
				maxNode = tuple[i].secondNode;
		}

		connectivityMap = new int[maxTime - minTime + 1];

		for (a = minNode; a <= maxNode; a++)
			for (b = a + 1; b <= maxNode; b++) {
				for (i = 0; i < connectivityMap.length; i++)
					connectivityMap[i] = 0;

				for (j = 0; j < tuple.length; j++) {
					if (tuple[j].firstNode == a && tuple[j].secondNode == b) {
						for (i = tuple[j].startTime; i < tuple[j].stopTime; i++)
							connectivityMap[i - minTime] = connectivityMap[i
									- minTime] | 1;
					}
					if (tuple[j].firstNode == b && tuple[j].secondNode == a) {
						for (i = tuple[j].startTime; i < tuple[j].stopTime; i++)
							connectivityMap[i - minTime] = connectivityMap[i
									- minTime] | 2;
					}
				}

				// FIXME: call other function to do different things here...
				// j is the value of the previous element in the connectivity
				// map.
				
				j = 0;
				startTime = 0;
				stopTime = 0;
				for (i = 0; i < connectivityMap.length; i++) {
					if (j == 0 && connectivityMap[i] != 0) {
						startTime = i + minTime;
						j = connectivityMap[i];
					}
					if (j != 0 && connectivityMap[i] == 0) {
						stopTime = i + minTime;
						j = connectivityMap[i];
						retval.add(new linkTuple(a, b, startTime, stopTime));
					}
				}
				if (j != 0) {
					stopTime = connectivityMap.length + minTime;
					retval.add(new linkTuple(a, b, startTime, stopTime));
				}
			}

		return retval.toArray(new linkTuple[0]);
	}

	public static Node parseXML(String xml) {
		try {
			InputSource iSource = new InputSource(new StringReader(xml));
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			Document doc = db.parse(iSource);
			doc.getDocumentElement().normalize();
			return (Node) doc.getDocumentElement();
		} catch (Exception e) {
		}
		return (Node) null;
	}

	public static String getTagContent(Node node) {
		if (node != null) {
			NodeList fstNm = ((Element) node).getChildNodes();
			if (fstNm != null) {
				if (fstNm.getLength() > 0) {
					return ((Node) fstNm.item(0)).getNodeValue();
				}
			}
		}
		return null;
	}

	public static String getTagContent(Node node, String element_name, int num) {
		if (node != null) {
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				NodeList nodes = getSubTags(node, element_name);
				if (nodes != null) {
					Element subElmnt = (Element) nodes.item(num);
					if (subElmnt != null) {
						NodeList fstNm = subElmnt.getChildNodes();
						if (fstNm != null) {
							if (fstNm.getLength() > 0) {
								return ((Node) fstNm.item(0)).getNodeValue();
							}
						}
					}
				}
			}
		}
		return null;
	}

	public static String getTagContent(Node node, String element_name) {
		return getTagContent(node, element_name, 0);
	}

	public static Node getSubTag(Node node, String element_name, int num) {
		if (node.getNodeType() == Node.ELEMENT_NODE) {
			// FIXME: figure out a faster way to create an empty node:
			Node tmp = node.cloneNode(false);
			while (tmp.hasChildNodes())
				tmp.removeChild(tmp.getFirstChild());

			NodeList children = node.getChildNodes();
			int i, j;

			j = 0;
			for (i = 0; i < children.getLength(); i++)
				if (children.item(i).getNodeName().equals(element_name)) {
					if (j == num)
						return children.item(i);
					j++;
				}
		}
		return null;
	}

	public static Node getSubTag(Node node, String element_name) {
		return getSubTag(node, element_name, 0);
	}

	public static NodeList getSubTags(Node node, String element_name) {
		if (node.getNodeType() == Node.ELEMENT_NODE) {
			// FIXME: figure out a faster way to create an empty node:
			Node tmp = node.cloneNode(false);
			while (tmp.hasChildNodes())
				tmp.removeChild(tmp.getFirstChild());

			NodeList children = node.getChildNodes();
			int i;

			for (i = 0; i < children.getLength(); i++)
				if (children.item(i).getNodeName().equals(element_name))
					tmp.appendChild(children.item(i));

			return tmp.getChildNodes();
		}
		return null;
	}

	static public String getContents(String filename) {
		File aFile = new File(filename);
		StringBuilder contents = new StringBuilder();

		try {
			BufferedReader input = new BufferedReader(new FileReader(aFile));
			try {
				String line = null;
				while ((line = input.readLine()) != null) {
					contents.append(line);
					contents.append(System.getProperty("line.separator"));
				}
			} finally {
				input.close();
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}

		return contents.toString();
	}

	static public String[] getLinesOfFile(String filename) {
		File aFile = new File(filename);
		ArrayList<String> lines = new ArrayList<String>();

		try {
			BufferedReader input = new BufferedReader(new FileReader(aFile));
			try {
				String line = null;
				while ((line = input.readLine()) != null) {
					String lineWithoutComment = line.split("#")[0];
					if (!lineWithoutComment.equals(""))
						lines.add(lineWithoutComment);
				}
			} finally {
				input.close();
			}
			return lines.toArray(new String[0]);
		} catch (IOException ex) {
			ex.printStackTrace();
		}
		return null;
	}

	static public int system(String cmd) {
		// System.out.println("Executing: " + cmd);
		try {
			Process p = Runtime.getRuntime().exec(cmd);
			BufferedWriter stdIn;
			stdIn = new BufferedWriter(new OutputStreamWriter(
					p.getOutputStream()));
			try {
				stdIn.close();
				p.waitFor();
				return p.exitValue();
			} catch (Exception e) {
			}
			p.waitFor();
			return p.exitValue();
		} catch (Exception e) {
		}
		return -1;
	}

	static public Process popen(String cmd) {
		// System.out.println("Executing: " + cmd);
		try {
			Process p = Runtime.getRuntime().exec(cmd);
			return p;
		} catch (Exception e) {
		}
		return null;
	}

	public static String pathFromFileName(String filename) {
		int i;
		String path = "";
		String[] path_element = filename.split("/");
		if (path_element != null)
			for (i = 0; i < path_element.length - 1; i++) {
				if (!path_element[i].equals(""))
					// path += "/" + path_element[i];
					path += path_element[i] + "/";
			}
		// path += "/";
		return path;
	}

	public static String getFileName(String filename) {
		String[] split = filename.split("/");
		if (split == null)
			return "";
		if (split.length < 1)
			return "";
		return split[split.length - 1];
	}

	public static int mySystem(String cmd) {
		if (controller)
			cmd = "do_quiet.sh " + controllerIP + " 9797 " + cmd;
		return system("./" + cmd);
	}

	public static int upload(String filename) {
		if (controller) {
			String cmd;
			Process p;
			BufferedWriter stdIn;
			String fileContents;

			cmd = "do.sh " + controllerIP + " 9797 " + "upload " + filename;
			p = popen(cmd);
			if (p != null) {
				stdIn = new BufferedWriter(new OutputStreamWriter(
						p.getOutputStream()));
				fileContents = getContents(filename);
				try {
					stdIn.write(fileContents, 0, fileContents.length());
					stdIn.close();
					p.waitFor();
					return p.exitValue();
				} catch (Exception e) {
				}
			}
		}
		return -1;
	}

	// Is a controller used?
	public static boolean controller;
	public static String controllerIP;
	public static String[] main_args;

	public static void main_run(String[] args) {
		
		int i;
		Date now = new Date();

		// input argument check
		if (args == null)
			return;
		if (args.length < 1) {
			System.out.println("Not enough input arguments.");
			return;
		}

		// Scenario file name:
		String scenario_file_name = null;
		// Is a controller used?
		controller = false;
		controllerIP = null;

		for (i = 0; i < args.length; i++) {
			if (args[i].equals("--run-with-controller")) {
				controller = true;
				if (args.length >= i + 1) {
					controllerIP = args[i + 1];
					i++;
				}
			} else {
				scenario_file_name = args[i];
			}
		}
		
		if (scenario_file_name == null) {
			System.out.println("No scenario file specified.");
			return;
		}

		// FIXME: Check that it is an actual address.
		if (controller && controllerIP == null) {
			System.out.println("No IP address specified.");
			return;
		}

		// read and parse scenario:
		Node scenario_file = parseXML(getContents(scenario_file_name));
		if (scenario_file == null) {
			System.out.println("Unable to load scenario file "
					+ scenario_file_name + ".");
			return;
		}

		parseScenario_ok = true;
		if (cancelButton_pressed)
			return;
		// Check "magic" string:
		// (See "man file" for why it's called "magic".
		String magic = getTagContent(scenario_file, "Magic");
		if (magic == null) {
			System.out.println("No magic tag!");
			return;
		}
		if (!magic.equals("haggle")) {
			System.out.println("Magic tag wrong!");
			return;
		}

		magicTag_ok = true;
		if (cancelButton_pressed)
			return;

		// Get scenario name:
		String scenario_name = getTagContent(scenario_file, "name");

		// Get number of iterations. If not specified the default is one
		// iteration. xxx
		int iterations = 1;
		int maxInteration = 1;
		
		String tmp1 = getTagContent(scenario_file, "Iterations");
		if (tmp1 != null){
			iterations = Integer.parseInt(tmp1);
			System.out.println("iterations: " + iterations);
		}
		
		String tmp2 = getTagContent(scenario_file, "maxInteration");
		if (tmp2 != null){
			maxInteration = Integer.parseInt(tmp2);
			System.out.println("maxInteration: " + maxInteration);
		}
		

		// Figure out the base path for all files:
		String scenario_path = pathFromFileName(scenario_file_name);

		// FIXME: check!
		scenarioFile_ok = true;
		if (cancelButton_pressed)
			return;

		System.out.println("scenario: " + scenario_path);

		nodeCount_ok = true;
		if (cancelButton_pressed)
			return;

		ArrayList<action> actions = new ArrayList<action>();
		int node1 = 0;
		int node2 = 0;
		int nodeCount = 0;
		int shutdownNode = 100;
		// Get the trace file name:
		String traceFile = getTagContent(scenario_file, "Tracefile");

		System.out.println("trace found: " + traceFile);

		if (traceFile == null) {
			System.out.println("TRACEFILE!");
			return;
		} else {
			readTraceFile_ok = true;
			if (cancelButton_pressed)
				return;
			traceFile = scenario_path + traceFile;

			// Go through the trace and create actions for the events in it:
			String[] trace = getLinesOfFile(traceFile);

			if (trace != null) {

				linkTuple[] tuple = parseLinkTuples(trace);

				int minNode = tuple[0].firstNode;
				int maxNode = tuple[0].firstNode;
				for (i = 0; i < tuple.length; i++) {
					if (tuple[i].firstNode < minNode)
						minNode = tuple[i].firstNode;
					if (tuple[i].secondNode < minNode)
						minNode = tuple[i].firstNode;
					if (tuple[i].firstNode > maxNode)
						maxNode = tuple[i].firstNode;
					if (tuple[i].secondNode > maxNode)
						maxNode = tuple[i].firstNode;
				}
				
				// nodeCount = (maxNode - minNode) + 1;
				nodeCount = maxNode + 1;
				// nodeCount = maxNode;

				minNode = 0;
				System.out.println("Total nodes: " + maxNode);
				
				//Preprocess
				String prep = getTagContent(scenario_file, "Preprocess");
				if (prep != null){
						// FIXME: preprocess:
						System.out.println("Preprocess start at: " + (new Date().getTime()/60000));
						tuple = preprocess(tuple);
				}
		
				for (i = 0; i < tuple.length; i++) {
					if (tuple[i] != null) {
						if (tuple[i].firstNode <= maxNode
								&& tuple[i].secondNode <= maxNode)
							if (tuple[i].firstNode < tuple[i].secondNode) {
								// In the trace, the nodes are called 1, 2, 3,
								// but in the testbed, the nodes are called
								// 0, 1, 2:
								String cmdUp = "linkup.sh node-"
										+ (tuple[i].firstNode - minNode)
										+ " node-"
										+ (tuple[i].secondNode - minNode);
								String cmdDown = "linkdown.sh node-"
										+ (tuple[i].firstNode - minNode)
										+ " node-"
										+ (tuple[i].secondNode - minNode);

								actions.add(new action(tuple[i].startTime,
										cmdUp));
								actions.add(new action(tuple[i].stopTime,
										cmdDown));
							}
					}
				}
			} else {
				System.out.println("Unable to load trace file " + traceFile
						+ ".");
				return;
			}
		}
		parseTraceFile_ok = true;
		if (cancelButton_pressed)
			return;
		
//		System.out.println("Preprocess end at: " + (new Date().getTime()/60000));
		
		// Get the data object list file name:
		String doListFile = getTagContent(scenario_file, "dolist");
		if (doListFile != null) {
			doListFile = scenario_path + doListFile;

			// Go through the data object insertion list and create actions:
			String[] doList = getLinesOfFile(doListFile);

			if (doList != null) {
				for (i = 0; i < doList.length; i++) {
					String[] value = doList[i].split("\t");

					if (value.length >= 4) {

					}
				}
			} else {
				System.out.println("Unable to load data object list file "
						+ doListFile + ".");
				return;
			}
		}
		
		readDOList_ok = true;
		if (cancelButton_pressed)
			return;
		
		int myStamp = 1;
		String tStamp = getTagContent(scenario_file, "TimeStamp");
		if (tStamp != null){
			myStamp = Integer.parseInt(tStamp);
			System.out.println("timeStamp: " + myStamp);
		}
		
		int myTimes = 0;
		int maxRuns = 0;
		
		String runTimes = getTagContent(scenario_file, "RunTimes");
		if (runTimes != null){
			myTimes = Integer.parseInt(runTimes);
			System.out.println("runTimes: " + myTimes);
		}
			
		// While loop start
		int run = 0;
		
		while (iterations <= maxInteration) {
			
			System.out.println("Interation starts at: " + (new Date().getTime()/60000));
			
			// FIXME: Shutdown any running Haggle.
			scenario_file = parseXML(getContents(scenario_file_name));
			if (scenario_file == null) {
				System.out.println("Unable to load scenario file "
						+ scenario_file_name + ".");
				return;
			}
		
			run++;
			// FIXME: Shutdown any running Haggle.
			// FIXME: And application!
			// Create execution log file.
			File oFile = new File(now.getTime() + ".log");
			PrintStream output = null;
			try {
				output = new PrintStream(new FileOutputStream(oFile));
			} catch (IOException ex) {
				ex.printStackTrace();
			}
			System.out.println("Log files created");

			clearNodes_ok = true;
			if (cancelButton_pressed)
				return;

			// Make sure they all started! errors for 100
			String startNodes = getTagContent(scenario_file, "startNodes");
			if (startNodes != null){
				if (mySystem("check_nodes.sh " + nodeCount) != 0) {
					System.out.println("Check nodes failed!");
					return;
				}
				System.out.println(nodeCount + " have been created");
			}
			

			System.out.println("clean all nodes.");
			//Before start close all program
			//neee
			mySystem("cleanallnodes.sh");
			
			checkNodes_ok = true;
			if (cancelButton_pressed)
				return;

			// Initialize filters.
			if (mySystem("initfilter.sh") != 0) {
				System.out.println("Init filters failed!");
				return;
			}

			// Upload configuration file.
			// upload common config.xml
			String cfgFileName = getTagContent(scenario_file, "Configuration");
			if (cfgFileName != null) {
				System.out.println("config: " + cfgFileName);
				mySystem("upload_file.sh " + scenario_path + cfgFileName + " config.xml " + nodeCount);
				System.out.println("Normal configuration file uploaded from " + scenario_path + cfgFileName);
			}
			
			//upload config according to different community detection -- label
			String camConf = getTagContent(scenario_file, "CamConfig");
			if (camConf != null) {
				System.out.println("py/upload4c.py config: " + camConf);
				mySystem("py/upload4c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("upload4c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("4 community configuration file uploaded from " + scenario_path + camConf);
			}
			
			//upload config according to random community detection -- label
			String comConf = getTagContent(scenario_file, "ComConfig");
			if (comConf != null) {
				System.out.println("py/upload.py config:" + comConf);
				mySystem("py/upload.py "+ scenario_path + " config.xml " + nodeCount+" "+comConf);
				System.out.println("upload.py "+ scenario_path + " config.xml " + nodeCount+" "+comConf);
				System.out.println("Random community configuration file uploaded from " + scenario_path +" "+comConf);
			}
			
			//upload config according to predefined rank -- rank
			String rankConf = getTagContent(scenario_file, "RankConfig");
			if (rankConf != null) {
				System.out.println("py/uploadRank config: " + rankConf);
				mySystem("py/uploadRank.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("uploadRank.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("Rank community configuration file uploaded from " + scenario_path + rankConf);
			}
			
			//upload config according to predefined setting
			String uploadLabelMit8c = getTagContent(scenario_file, "uploadLabelMit8c");
			if (uploadLabelMit8c != null) {
				System.out.println("config: " + uploadLabelMit8c);
				mySystem("py/uploadLabelMit8c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("uploadLabelMit8c.py "+ scenario_path + " config.xml " + nodeCount);
			}
			
			String uploadLabelnfc6c = getTagContent(scenario_file, "uploadLabelnfc6c");
			if (uploadLabelnfc6c != null) {
				System.out.println("config: " + uploadLabelnfc6c);
				mySystem("py/uploadLabelnfc6c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("uploadLabelnfc6c.py "+ scenario_path + " config.xml " + nodeCount);
			}
			
			String uploadRankMit = getTagContent(scenario_file, "uploadRankMit");
			if (uploadRankMit != null) {
				System.out.println("config: " + uploadRankMit);
				mySystem("py/uploadRankMit8c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("uploadRankMit.py "+ scenario_path + " config.xml " + nodeCount);
			}
			
			String uploadRankCam4c = getTagContent(scenario_file, "uploadRankCam4c");
			if (uploadRankCam4c != null) {
				System.out.println("config: " + uploadRankCam4c);
				mySystem("py/uploadRankCam4c.py "+ scenario_path + " config.xml " + nodeCount);
				System.out.println("uploadRankCam4c.py "+ scenario_path + " config.xml " + nodeCount);
			}		
			
			
			//upload other files cp one file with node_name
			String anyFileName = getTagContent(scenario_file, "File");
			if (anyFileName != null) {
				System.out.println("upload: " + anyFileName);
				mySystem("upload_file.sh " + scenario_path + anyFileName + " "+ anyFileName + " " + nodeCount);
				System.out.println("Other files uploaded from " + scenario_path + anyFileName);
			}

			initFilter_ok = true;
			if (cancelButton_pressed)
				return;

			// Start haggle on each node:
			String networkArch = getTagContent(scenario_file, "Architecture");
			System.out.println("starting Haggle... " + networkArch);
			for (i = 0; i < nodeCount; i++) {
				mySystem("start_program_on_node.sh " + "node-" + i + " "
						+ networkArch);
			}

			System.out.println("Haggle started");

			
			startHaggle_ok = true;
			if (cancelButton_pressed)
				return;
			// FIXME: make sure haggle started!
			// Wait until haggle has initialized.
			try {
				Thread.sleep(15000);
			} catch (Exception e) {
				System.out.println("Error");
			}

			// Get the file name/path of the application to start:
			// needneed to do here: all nodes run the same app
			//run applications
			String appName = getTagContent(scenario_file, "Application");
			if (appName != null) {
				System.out.println("starting application... " + appName);
				for (i = 0; i < nodeCount; i++) {
					mySystem("start_app.sh" + " node-" + i + " "+ appName);
				}
				System.out.println(appName + " started");			
			}
					
			//run app according cambrige inter- intra- scenario
			String scenarioNum = getTagContent(scenario_file, "AppRunBySce");
			if (scenarioNum != null)
			{
				mySystem("run_app_by_scenario.py "+ iterations);
				System.out.println("started: run_app_by_scenario.py " + iterations + " times: " + scenarioNum);
			}
			
			String runOrder = getTagContent(scenario_file, "AppRunByOrder");
			if (runOrder != null)
			{
				mySystem("run_app_by_order.py "+ nodeCount);
				System.out.println("start: run_app_by_order.py " + nodeCount);
			}


			startApplication_ok = true;
			if (cancelButton_pressed)
				return;
			// FIXME: make sure the application started!
			// Wait until application has initialized.
			try {
				Thread.sleep(15000);
			} catch (Exception e) {
				System.out.println("Error");
			}

			// Sort the action list on time of execution.
			Collections.sort(actions, new actionComparator());

			// An array is easier to access:
			action[] event = actions.toArray(new action[0]);

			String showEvent = getTagContent(scenario_file, "ShowEvent");

			if (myTimes!=0)
			{
				maxRuns=myTimes;
			}
			else
			{
				maxRuns=event.length;	
			}
				
			// Run the scenario:
			if (event.length > 0) {
				System.out.println("start scenario...");

				runScenarioBar_max = (int) event[event.length - 1].timestamp;
				long done;
				long start = done = new Date().getTime();
				System.out.println("Testbed started on "+start);
				System.out.println("Event length:" + event.length);

				output.println("Real Start time:" + start);
				output.println("Event length:" + event.length);
				
//				BIGCHANGE ADD myTimes
				for (i = 0; i < maxRuns; i++) {
					
					long time_to_sleep = (start + event[i].timestamp * myStamp)
							- done;
					
					if (time_to_sleep > 0) {
						try {
							Thread.sleep(time_to_sleep);
						} catch (Exception e) {
							System.out.println("Errors");
						}
					}
//					make the topology
					mySystem(event[i].cmd);
					done = new Date().getTime();
					output.println(event[i].cmd + " " + done);
					if (showEvent != null)
					{
						System.out.println(i+" "+event[i].cmd + " time: " + done);
					}
					
					runScenarioBar_value = (int) event[i].timestamp;
				}
				
				long used_time = (new Date().getTime()-start)/(60*1000);
				System.out.println("Totally used time: " + used_time+ " min");
				output.println("Totally used time: " + used_time+ " min");
			
			}

			runScenario_ok = true;
			if (cancelButton_pressed)
				return;

			output.close();

			try {
				Thread.sleep(15000);
			} catch (Exception e) {
			}

			// stop haggle and application
			System.out.println("stopping haggle and to stop application");
			
			mySystem("stop_all_program.sh " + nodeCount +" "+ appName);
/*
			for (i = 0; i < nodeCount; i++) {
				mySystem("stop_program_on_node.sh " + "node-" + i + " haggle");
			}
*/
			
			// The reason for not placing the two ssh commands in one is to make
			// the nodes shut down faster by allowing them to shut down
			// simultaneously.
			// Make sure all nodes have stopped running haggle:
			for (i = 0; i < nodeCount; i++) {
				System.out.print("  node-" + i + "... ");
				mySystem("wait_for_app_to_stop.sh" + " node-" + i + " haggle");
				System.out.println("ok");
			}
			stopHaggle_ok = true;
			if (cancelButton_pressed)
				return;

			// Collect and save logs.
			
			String ctd = getTagContent(scenario_file, "CollectToDir");
			if (ctd != null) {
				System.out.println("CollectToDir...");
				mySystem("collect_logs_dir.sh " + nodeCount + " " + iterations + " "
					+ scenario_path);
			}
			else
			{
				System.out.println("Collect logs");
				mySystem("collect_logs.sh " + nodeCount + " " + iterations + " "
					+ scenario_path);	
			}

			saveLogs_ok = true;

			if (cancelButton_pressed)
				return;
			// Decrease number of iterations left.
			iterations++;
			
			System.out.println("Clean nodes to finish");
			mySystem("clean_nodes.sh " + nodeCount);
			
			String shutNode = getTagContent(scenario_file, "ShutdownNode");
			if (shutNode != null){
				// Shutdown all nodes.
				System.out.println("Shutting down all nodes.");
				mySystem("shutdown_nodes.sh " + nodeCount);
			}


		}

		System.out.println("done");
	}

	private static boolean is_running_with_gui;
	private static boolean should_dump_to_log;
	private static boolean should_dump_to_log_occasionally;
	private static boolean is_finished;

	public void run() {
		main_run(main_args);

		// FIXME: enable "OK" button or whatever.

		// Tell the main thread that we're done:
		is_finished = true;
	}

	public static JCheckBox makeNewCheckbox(JPanel inPanel, String title) {
		JCheckBox retval;
		retval = new JCheckBox(title);
		retval.setSelected(false);
		retval.setEnabled(false);
		inPanel.add(retval);
		return retval;
	}

	static private class boxAndBar {
		public JCheckBox box;
		public JProgressBar bar;

		boxAndBar(JCheckBox _box, JProgressBar _bar) {
			box = _box;
			bar = _bar;
		}
	};

	public static boxAndBar makeNewCheckboxAndProgressBar(JPanel inPanel,
			String title) {
		JCheckBox box;
		JProgressBar bar;
		JPanel panel;

		panel = new JPanel();
		panel.setLayout(new BoxLayout(panel, BoxLayout.LINE_AXIS));

		box = new JCheckBox(title);
		box.setSelected(false);
		box.setEnabled(false);

		bar = new JProgressBar(0, 0);
		bar.setValue(0);
		bar.setEnabled(true);
		// FIXME: set indeterminate state:
		// bar.set...

		panel.add(box);
		panel.add(bar);
		panel.add(Box.createHorizontalGlue());

		inPanel.add(panel);

		return new boxAndBar(box, bar);
	}

	public static JButton makeNewButton(JPanel inPanel, String title,
			boolean enabled, boolean isDefault) {
		JButton retval;
		retval = new JButton(title);
		retval.setSelected(false);
		retval.setEnabled(enabled);
		retval.setDefaultCapable(isDefault);
		inPanel.add(retval);
		return retval;
	}

	public static boolean parseScenario_ok, magicTag_ok, scenarioFile_ok,
			nodeCount_ok, readTraceFile_ok, parseTraceFile_ok, readDOList_ok,
			clearNodes_ok, checkNodes_ok, initFilter_ok, startHaggle_ok,
			startApplication_ok, runScenario_ok, stopApplication_ok,
			stopHaggle_ok, saveLogs_ok, removeLogs_ok, okButton_pressed,
			cancelButton_pressed;
	public static int runScenarioBar_max, runScenarioBar_value;

	public static void main(String[] args) {

		main_args = args;
		is_finished = false;

		// FIXME: are we running with a GUI, etc.?
		is_running_with_gui = false;
		should_dump_to_log = false;
		should_dump_to_log_occasionally = false;

		if (should_dump_to_log) {
			// FIXME: set up to write to log.
		}

		// Start running the test:
		Thread thread = new Thread(new scenariorunner3());
		if (thread != null)
			thread.start();
		else {
			is_finished = true;
			// FIXME: note that the thread wouldn't start!
		}

		while (!is_finished) {
			try {
				Thread.sleep(1000);
			} catch (Exception e) {
			}

			if (should_dump_to_log_occasionally
					|| (is_finished && should_dump_to_log)) {
				// FIXME: dump to file.
			}

			// FIXME: did the user press cancel?
		}

	}
}
