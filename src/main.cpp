#define _USE_MATH_DEFINES
#include <iostream>
#include <ws2tcpip.h>
#include <string>
#include <fstream>
#include "holodaye/elevation.h"
#include "holodaye/output.h"
#include <math.h>
#include <vector>
#include <sstream>
#include "holodaye/utils.h"
#include <iomanip>
#include <list>


#pragma comment (lib, "ws2_32.lib")

using namespace std;

void main()
{		
	// // Test Algo
    float x = 2683691;
    float y = 1247833;
	// float z = 465.52;
	float angle = 0;
	int length = 1;
    // ElevationData *data = new ElevationData();
    cout << "line 27" << endl;
	ElevationData* data = new ElevationData();
    cout << data->getResolution() << endl;
    cout << "line 28" << endl;
	ElevationAngle eleAngle(length, x, y, data);
	cout << "line 31" << endl;
	eleAngle.FindPeakInCircle();
	
    
	list <list<double>> result;	
	for (int i = 0; i < 30; i++){
		x = eleAngle.border_d_[i] * cos(i / 180 * M_PI);
		y = eleAngle.border_d_[i] * cos(i / 180 * M_PI);
		Struct1 gps = LV952GPS(x, y, eleAngle.border_h_[i]);
		result.push_back({gps.lat, gps.lon, gps.alt});
	}

	cout << "line 41" << endl;
	printNestedList(result);

	// test
	// double lat = 47.37602004225053;
    // double lon = 8.546809259609395;
	// Struct2 lv95 = GPS2LV95(lon, lat);
	
    // cout << "E is:" << lv95.E << " and N is " << lv95.N << "             ";
	// double height = 30000.5;
	// Struct1 gps = LV952GPS(lv95.E, lv95.N, height);

	// double E_ = ((double)lv95.E - 2600000) / 1000000;
	// cout << E_ << "                 ";

	// cout << "longitude is:" << gps.lon << " and latitude is " << gps.lat;

	// ----------------------------------------------server----------------------------------------
	// Initialze winsock
	WSADATA wsData;
	WORD ver = MAKEWORD(2, 2);

	int wsOk = WSAStartup(ver, &wsData);
	if (wsOk != 0)
	{
		cerr << "Can't Initialize winsock! Quitting" << endl;
		return;
	}
	
	// Create a socket
	SOCKET listening = socket(AF_INET, SOCK_STREAM, 0);
	
	if (listening == INVALID_SOCKET)
	{
		cerr << "Can't create a socket! Quitting" << endl;
		return;
	}

	// Bind the ip address and port to a socket
	sockaddr_in hint;
	hint.sin_family = AF_INET;
	hint.sin_port = htons(54000);
	hint.sin_addr.S_un.S_addr = INADDR_ANY; // Could also use inet_pton .... 
	
	bind(listening, (sockaddr*)&hint, sizeof(hint));

	// Tell Winsock the socket is for listening 
	listen(listening, SOMAXCONN);
	//cout << listen(listening, SOMAXCONN) << endl;

	// Wait for a connection
	sockaddr_in client;
	int clientSize = sizeof(client);



	SOCKET clientSocket = accept(listening, (sockaddr*)&client, &clientSize);
	//cout << clientSocket << endl;

	char host[NI_MAXHOST];		// Client's remote name
	char service[NI_MAXSERV];	// Service (i.e. port) the client is connect on

	ZeroMemory(host, NI_MAXHOST); // same as memset(host, 0, NI_MAXHOST);
	ZeroMemory(service, NI_MAXSERV);

	if (getnameinfo((sockaddr*)&client, sizeof(client), host, NI_MAXHOST, service, NI_MAXSERV, 0) == 0)
	{
		cout << host << " connected on port " << service << endl;
	}
	else
	{
		inet_ntop(AF_INET, &client.sin_addr, host, NI_MAXHOST);
		cout << host << " connected on port " <<
			ntohs(client.sin_port) << endl;
	}

	// Close listening socket
	closesocket(listening);
	
	
	

	// While loop: accept and echo message back to client
	char buf[4096];

	while (true)
	{	
		

		ZeroMemory(buf, 4096);

		// Wait for client to send data
		int bytesReceived = recv(clientSocket, buf, 4096, 0);
		if (bytesReceived == SOCKET_ERROR)
		{
			cerr << "Error in recv(). Quitting" << endl;
			//continue;
			break;
		}

		if (bytesReceived == 0)
		{
			cout << "Client disconnected " << endl;
			break;
			//continue;
		}

		string received = string(buf, 0, bytesReceived);
		// cout << received << endl;

		// Read the data from cliend and process the data
		vector<double> vect;

		stringstream ss(received);

		for (double i; ss >> i;) {
			vect.push_back(i);
			if (ss.peek() == ',')
				ss.ignore();
		}

		// [lat, lon]
		Struct2 input = GPS2LV95(vect[0], vect[1]);
		cout << "The message received from client: " << endl;
		for (size_t i = 0; i < vect.size(); i++)
			cout << setprecision(15) << vect[i] << endl;

// ----------------------------------------------server----------------------------------------
		// Echo message back to client
		// send(clientSocket, buf, bytesReceived + 1, 0);

		// Send message to client
		// string userInput;
		// getline(cin, userInput);
		// int sendResult = send(clientSocket, userInput.c_str(), userInput.size() + 1, 0);

		// Call holodaye function
		
		// string message_1 = to_string(eleAngle.border_d_[10]) + " Woshinidie ";

		// string message_2 = to_string(eleAngle.border_h_[10]) + " Woyoubushinidie ";


		// string message_3 = to_string(eleAngle.max_slope_[10]) + " CaiCaiwoshishei ";

		// string message = message_1 + message_2 + message_3;
		// //cout << message << endl;
		// send(clientSocket, message.c_str(), message.size() + 1, 0);


		// Convert the result to string stream and send back to client
		list<string> message_list;
		list <list<double>> result({{1.0896564839292, 47.37602004225053, 8.546809259609395}, {24.0896789839292, 33.39872004225053, 12.546890259609395}});
		for (auto& outer : result)
		{
			for (auto& inner : outer)
			{
    			stringstream ss;
				ss << fixed << setprecision(15) << inner;
				message_list.push_back(ss.str());
			}
		}

		ostringstream stream;

		copy(message_list.begin(), message_list.end(), ostream_iterator<string>(stream, ","));
		string message = stream.str();

		send(clientSocket, message.c_str(), message.size() + 1, 0);

		// // Close the socket
		
	
	}
	closesocket(clientSocket);
	
	

	// Cleanup winsock
	WSACleanup();

	system("pause");
}
