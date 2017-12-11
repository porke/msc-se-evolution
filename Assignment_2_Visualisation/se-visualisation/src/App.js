import React, { Component } from 'react';
import './App.css';

import { Grid, Row, Col, Tabs, Tab, Table } from 'react-bootstrap';	


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
							<Tab eventKey={2} title="Clone Classes"><CloneVisualisation clones={this.props.data["clone-report"]["clone-classes"]}/></Tab>						
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

class CloneVisualisation extends Component {
	render() {		
		return (<p>Hello, I'm the clone visualisation!</p>);
	}
}

export default App;
