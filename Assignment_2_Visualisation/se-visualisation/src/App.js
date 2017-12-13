import React, { Component } from 'react';
import './App.css';

import { Grid, Row, Col, Tabs, Tab, Table, ListGroup, ListGroupItem, Accordion, Panel, Well } from 'react-bootstrap';	


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
		const fileEntries = this.props.files.map((attr) =>
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
		const instances = this.props.instances.map((instance) =>
		{
			return <ListGroupItem key={instance["clone-text"]}>{instance["file"]} lines:{instance["start"]}-{instance["end"]}</ListGroupItem>
		});
		
		return (<div><Well>{this.props.cloneText}</Well> <ListGroup>{instances}</ListGroup></div>);
	}
}

class CloneClassList extends Component {	
	render() {		
		const cloneClassEntries = this.props.clones.map((clone) =>
		{
			return <Panel header={"Clone Size: " + clone["clone-text"].length + " characters, Clone Instances: " + clone["clone-instances"].length} eventKey="1">
						<CloneClassEntry key={clone["clone-text"]} cloneText={clone["clone-text"]} instances={clone["clone-instances"]}/>
					</Panel>
		});
	
		return (<Accordion>{cloneClassEntries}</Accordion>);
	}
}

class FileDuplicationEntry extends Component {
	render() {
		return (<p>Hello, I'm a file duplication entry!</p>);
	}
}

class FileList extends Component {
	render() {
		return (<p>Hello, I'm the file list</p>);
	}
}

export default App;
