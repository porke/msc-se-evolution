import React, { Component } from 'react';
import './App.css';

import { Grid, Row, Col, Tabs, Tab, Table, ListGroup, ListGroupItem, Accordion, Panel } from 'react-bootstrap';	


class App extends Component {	
	render() {			
		return (	
		<div className="App">	  
			<Grid>
				<Row className="show-grid">
					<Col sm={1}/>
					<Col sm={10}>
						<Tabs defaultActiveKey={1} id="uncontrolled-tab-example">							
							<Tab eventKey={1} title="Report"><Report attributes={this.props.data["clone-report"]["report"]} files={this.props.data["clone-report"]["files"]}/></Tab>
							<Tab eventKey={2} title="Clone Classes"><CloneClassList clones={this.props.data["clone-report"]["clone-classes"]}/></Tab>						
							<Tab eventKey={3} title="Files"><FileList clones={this.props.data["clone-report"]["clone-classes"]} files={this.props.data["clone-report"]["files"]}/></Tab>						
						</Tabs>
					</Col>
					<Col sm={1}/>
				</Row>
			</Grid>
		</div>
		);
	}
}

class ReportEntry extends Component {
	render() {
		return (<tr>
					<td>{this.props.name}</td>
					<td>{this.props.value}</td>
				</tr>);
	}
}

class ReportTable extends Component {
	render() {
		const reportItems = this.props.attributes.map((attr) =>
		{
			return <ReportEntry key={attr["attribute"]} name={attr["attribute"]} value={attr["value"]}/>
		});
		
		return (<Table striped bordered hover>
					<thead>
					<tr>
						<th>Attribute</th>
						<th>Value</th>
					</tr>
					</thead>
					<tbody>{reportItems}</tbody>
				</Table>);
	}
}

class FileEntry extends Component {
	render() {
		return (<tr>
					<td>{this.props.filename}</td>
					<td>{this.props.lines}</td>
				</tr>);
	}
}

class FileTable extends Component {
	render() {
		function compareFiles(a,b) {		  
		  if (parseInt(a["size"]) < parseInt(b["size"])) return 1;
		  if (parseInt(a["size"]) > parseInt(b["size"])) return -1;
		  return 0;
		}
		
		const fileEntries = this.props.files.sort(compareFiles)
											.map((attr) =>
		{
			return <FileEntry key={attr["location"]} filename={attr["location"]} lines={attr["size"]}/>
		});
		
		return (<Table striped bordered hover>
				<thead>
				<tr>
					<th>Filename</th>
					<th>Line Count</th>
				</tr>
				</thead>
				<tbody>{fileEntries}</tbody>
			</Table>);
	}
}


class Report extends Component {
	render() {		
		return (<div>
					<ReportTable attributes={this.props.attributes}/>
					<FileTable files={this.props.files}/>
				</div>);
	}
}

class CloneClassEntry extends Component {
	render() {						
		const instances = this.props.instances.map((instance, index) =>
		{
			return <ListGroupItem key={index}>{instance["file"]} lines:{instance["start"]}-{instance["end"]}</ListGroupItem>
		});
		
		var cloneLines = this.props.cloneText.split("\r\n")
											 .filter((line) => line !== ' ' && line !== '' && line !== '\t')
											 .map((line) =>
		{
			return <div>{line}</div>;
		});
			
		return (<div><pre><code>{cloneLines}</code></pre><ListGroup>{instances}</ListGroup></div>);
	}
}

class CloneClassList extends Component {	
	render() {
		function compareCloneClasses(a,b) {			
			var instanceA = a["clone-instances"][0];
			var instanceB = b["clone-instances"][0];
			var lengthA = parseInt(instanceA["end"]) - parseInt(instanceA["start"]);
			var lengthB = parseInt(instanceB["end"]) - parseInt(instanceB["start"]);
			if (lengthA < lengthB) return 1;
			if (lengthA > lengthB) return -1;
			return 0;
		}
		
		const cloneClassEntries = this.props.clones.sort(compareCloneClasses)
												   .map((clone, index) =>
		{
			var cloneLines = clone["clone-text"].split("\r\n");			
			return <Panel key={index} header={"Clone Size: " + cloneLines.length + " lines, Clone Instances: " + clone["clone-instances"].length} eventKey={index}>
						<CloneClassEntry key={clone["clone-text"]} cloneText={clone["clone-text"]} instances={clone["clone-instances"]}/>
					</Panel>
		});
	
		return (<Accordion>{cloneClassEntries}</Accordion>);
	}
}

class ClonedSection extends Component {
	render() {
		return <p>Cloned section here!</p>;
	}
}

class FileDuplicationEntry extends Component {
	render() {
		var cloneInstanceEntry = (<rect y="123" width="120" height="12" fill="green"/>);
		
		const pixelsPerLine = 16;
		const fileEntryWidth = 120;
		const dividerWidth = 10;
		
		var filename = this.props.fileName.substr(this.props.fileName.lastIndexOf('/') + 1);
		filename = filename.substr(0, filename.length - 1);
		
		var translation = "translate(" + (this.props.displayIndex * (fileEntryWidth + dividerWidth)) + ")";
		return (<g class="sprite" id={this.props.displayIndex} transform={translation} width={fileEntryWidth} height={this.props.fileSize * pixelsPerLine}>
					<rect width={fileEntryWidth} height={this.props.fileSize * pixelsPerLine} fill="white" stroke="black"/>
					<rect width={fileEntryWidth} height="24" fill="gray" stroke="black"/>
					<text x={fileEntryWidth / 2} y="16" text-anchor="middle" font-size="9">{filename}</text>
						{cloneInstanceEntry}
				</g>);
	}
}

class FileList extends Component {
	render() {
		var files = this.props.files.map((file, index) =>
		{
			return <FileDuplicationEntry displayIndex={index} fileName={file["location"]} fileSize={file["size"]}/>;
		});
				
		return (<svg viewBox="-5 -5 600 600">{files}</svg>);
	}
}

export default App;
