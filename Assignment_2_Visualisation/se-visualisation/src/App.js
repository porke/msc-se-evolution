import React, { Component } from 'react';
import './App.css';

import { Grid, Row, Col, Tabs, Tab } from 'react-bootstrap';	


class App extends Component {	
	render() {			
		return (	
		<div className="App">	  
			<Grid>
				<Row className="show-grid">
					<Col sm={1}/>
					<Col sm={10}>
						<Tabs defaultActiveKey={1} id="uncontrolled-tab-example">							
							<Tab eventKey={1} title="Report"><Report files={this.props.data["clone-report"]["files"]}/></Tab>
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

class Report extends Component {
	render() {		
		return (<p>Hello, I'm the report! And this is my text: {this.props.files[0].location}</p>);
	}
}

class CloneVisualisation extends Component {
	render() {		
		return (<p>Hello, I'm the clone visualisation!</p>);
	}
}

export default App;
