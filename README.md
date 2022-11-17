# Egnyte-TestTask

To develop the task, I decided to devise a solution based on Clean Architecture with MVVM as scalable one. The monolith decoupled to modules behind interfaces:

<img width="1151" alt="Screenshot 2022-10-14 at 19 36 42" src="https://user-images.githubusercontent.com/3342474/202514709-955a3766-0b3c-4328-b5fd-b8098d92b593.png">

- Domain layer:
	Entity;
	FetchDataUseCases;

- Presenters:
	RootViewModel;
	ImageViewModel;

- UI: 
	RootViewController;
	ImageTableViewCell;

- DataLoader:
	DownloadingDataService;

- Network layer: 
	NetworkService;
  
<img width="580" alt="Screenshot 2022-10-16 at 20 13 44" src="https://user-images.githubusercontent.com/3342474/202514930-4f9153d7-4a15-459c-97db-9a3119aee4dc.png">

The Network Service has composition with NetworkSessionManager which is responsible for the URLSession connection and configuration based on URLSessionConfiguration.
DownloadingDataService for the moment has simple solution and correct position in the architecture. It can be extended in the future.

The Domain level is responsible for business task and has own data models and use cases that perform solutions. I would mark up the Domain layer as important layer that describes the business requirements and helps to build necessary components in the other layers based on the patterns: Repository, Data Providers, Networking, Presenters, Adapters.

I use to develop the solutions based on Combine API(Apple). Because, it is native framework and very handy for reactive programming. Just for clear understanding the Combine is based on there main instances: Publisher, Subscription and Subscriber. Publisher provides the Subscription to a Subscribers. The diagram below shows that well. As an abstract schema it shows that the Publisher makes close connect to the URLSession via Subscriber and creates the URLDownloadTask.

<img width="1680" alt="Screenshot 2022-10-16 at 21 01 56" src="https://user-images.githubusercontent.com/3342474/202515695-5b36a87e-29d5-46b9-bde5-276eb155dbc7.png">

The cells view models starts the downloading process based on supported connections by URLSession(by default 6 max). You can see the progress of images loading in concurrency 

To configure URL the project has the config files which has the host, service parameters. In the project this files are AppConfigurator.plist, Images.plist. I think to provide the config files, there are many strategies like remotely form backend or cloud storage services or at the CI/DI process. There are many solution to avoid hardcoding approach.

The AppDIContainer, this is very simple solution of Dependency Injection tool. In my practice I loved using the Swinject framework and developed my own solution based on open sources. I’ve applied that experience on the last project: MyFitnessPal.

The Unit Tests for the layers give a picture of layer independency. That approach makes the solution testable and scalable in the feature.

From my view point the benefits of that approach are
	- Testable solution, and supported TDD;
	- The concurrent development of every module;
	- Scalable solution;
	- Replaceable module in advance or in FDD;
	- Suite to Scrum Agile methodology;

Guys, don’t judge me stronger, yes, I didn’t provide the UI tests, don’t have so huge experience for that. Only simple UI Tests like getting the UI components and check for them the style settings: fonts, attributes, colours, content modes….etc. The table view might include tests for cell reusable id and registration for cells with that id.
