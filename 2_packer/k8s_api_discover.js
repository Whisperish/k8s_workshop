
function updatenodePorts(r) {

    // The following subrequest queries the K8s API server to find the set of nodeports defined for the service of service name set below

    r.subrequest ('/servicelist','',function(res) {

	if (res.status = 200) {
            // The variable below must be set to whatever name is given to the k8s service object pointing to the replicaset of NGINX PLUS Ingress Controllers.
	    // This service must have nodePorts defined for at least one name: 'http', 'https' below.
	    // The k8s API-based service discovery will only work if the three variables below match the service definitions within the k8s environment.
	    // If they don't match, they will not be available for automatic population within the upstream groups.

	    var ingress_service_name = 'nginx-ingress-service';
            var http_service_name    = 'port80';
            var https_service_name   = 'port443';
            var nginx_plus_api_name  = 'port8088';

	    var nodeport_array       = [];
	    var service_name_array   = [];
            var port_name_array      = [];

            var http_surface_port ;
            var https_surface_port ;
            var nginx_plus_api_surface_port ;

            var myJSON               = res.responseBody;
            var myObj                = JSON.parse(myJSON);

	    for (var counter in myObj.items) {
                service_name_array[counter] = myObj.items[counter].metadata.name;
                if (service_name_array[counter] = ingress_service_name) {
		    for (var counter3 in myObj.items[counter].spec.ports) {
                            port_name_array[counter3] = myObj.items[counter].spec.ports[counter3].name;
			    switch ( port_name_array[counter3] ) {
			        case http_service_name :
			            http_surface_port = myObj.items[counter].spec.ports[counter3].nodePort;
			            break;
                                case https_service_name :
                                    https_surface_port = myObj.items[counter].spec.ports[counter3].nodePort;
			            break;
                                case nginx_plus_api_name :
                                    nginx_plus_api_surface_port = myObj.items[counter].spec.ports[counter3].nodePort;
                                    break;
                                }
			    nodeport_array[counter3]  = myObj.items[counter].spec.ports[counter3].nodePort;
		    }
		}
	    } 

	    var log_string = 'k8s Service: '+ingress_service_name+', k8s nodePorts: ';
	    for (var counter2 in nodeport_array) {
                log_string = log_string + ' , ' + port_name_array[counter2] + ':' + nodeport_array[counter2];
	    }
            log_string = log_string + '\r\n'
                                    + 'HTTP:   ' + http_surface_port
			            + '\r\nHTTPS:  ' + https_surface_port
			            + '\r\nN+ API: ' + nginx_plus_api_surface_port + '\r\n';

            r.log (200,log_string);
	    }
	else {
            r.return(200,'Subrequest error - getting the nodePort numbers failed to work properly!');
	}

        // The following subrequest queries the k8s API server's pod list, and finds a list of Node IPs that have an ingress controller pod living on them.
        // In the case that more than one ingress controller pod is living on a particular Node, multiple entries will be supported to ensure
        // load balancing is equal across all ingress controllers.

        r.subrequest('/podlist', '' , function(res) {

            var json = JSON.parse(res.responseBody);
            var ingresspodlist = [];
            var ingresspodnamelist = [];
            var pod_name_prefix = 'nginx-ingress';
            var ingress_pods_detected = 0;

            for (var podcounter in json.items ) {
                var podfullname ;
                var podshortname ;

                podfullname = json.items[podcounter].metadata.name;
                podshortname = podfullname.substr(0,13);

                if ( podshortname == pod_name_prefix ) {
                    ingresspodlist[ingress_pods_detected] = json.items[podcounter].status.hostIP;
                    ingresspodnamelist[ingress_pods_detected] = podshortname;
                    ingress_pods_detected=ingress_pods_detected +1;
                }
            }

            // The following subrequest obtains the total number of IP+port combinations in the Upstream group

            var post_body = [];

            r.subrequest('/api/6/stream/upstreams/k8s_https_cluster_surface', '' , function(res) {
                if (res.status != 200) {
                    r.return(res.status,'oops');
                    return;
                }
                var json = JSON.parse(res.responseBody);
                var ipportentries = json.peers;
                var numberofipportentries = ipportentries.length;
                var numberofipportentries = json.peers.length;

                var num = https_surface_port;
                
                // The following subrequest adds the IP+Port combinations derived list of Nodes running ingress pods
                // to the NGINX PLUS upstream group via the NGINX PLUS API

                for ( var subrequestcounter in ingresspodlist ) {
                    post_body[subrequestcounter] = 
                              "{ \"server\": \""
                              + ingresspodlist[subrequestcounter]
                              + ":"
                              + num
                              +  '\", \"weight\": 1, \"max_conns\": 0, \"max_fails\": 0, \"fail_timeout\": \"10s\", \"slow_start\": \"10s\", \"backup\": false, \"down\": false }';

                    r.subrequest('/api/6/stream/upstreams/k8s_https_cluster_surface/servers', { method: 'POST', body: post_body[subrequestcounter]} , function(res) {
                        if (res.status != 201) {
                            r.return(res.status,'We have barfed trying to add new servers to the upstream group....');
                            return;
                        }
                    });
                }
                //var json = JSON.parse(res.responseBody);
                //r.return(200, post_body);

                // The following subrequest deletes all original IP+port combinations from the list of Nodes running ingress pods

                var debugstring = 'List of deleted objects: ';

                for ( var subrequestcounter in ipportentries ) {
                    r.subrequest('/api/6/stream/upstreams/k8s_https_cluster_surface/servers/'+ipportentries[subrequestcounter].id, { method: 'DELETE', body: '' } , function(res) {
                        if (res.status != 200) {
                            r.return(res.status,'We have barfed trying to add new servers to the upstream group....');
                            return;
                        }
                    //r.return(res.status,res.body);
                    });
                debugstring=debugstring+ipportentries[subrequestcounter].id+' , ';

                }

                r.return (200,'all done'+ipportentries.length+ipportentries+debugstring);
            });
        });
    });

}
