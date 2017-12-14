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
			console.log(line);
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

class FileDuplicationEntry extends Component {
	render() {
		return (<svg width="100" height="100">
					<circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" />
				</svg>);
	}
}

class FileList extends Component {
	render() {
		return (<p>Hello, I'm the file list <FileDuplicationEntry/></p>);
	}
}

export default App;
