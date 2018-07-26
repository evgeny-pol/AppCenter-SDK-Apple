#import "MSDeploymentInstanceTests.h"
#import "MSAssetsDeploymentInstance.h"
#import "MSTestFrameworks.h"
#import "MSAssets.h"

@interface MSDeploymentInstanceTests (Sync)

@end

@implementation MSDeploymentInstanceTests (Sync)

//#pragma MARK: Sync tests
- (void)testSyncNotCalled {
    
    // If
    id serviceMock = OCMClassMock([MSAssets class]);
    OCMStub(ClassMethod([serviceMock isEnabled])).andReturn(NO);
    id assetsMock = OCMPartialMock(self.sut);
    OCMReject([assetsMock notifyAboutSyncStatusChange:[OCMArg any] instanceState:OCMOCK_ANY]);
    
    // When
    [assetsMock sync:[MSAssetsSyncOptions new]];
    
    // Then
    OCMVerifyAll(assetsMock);
    [assetsMock stopMocking];
}

- (id)mockSyncDelegate {
    id delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));
    OCMStub([delegateMock syncStatusChanged:OCMOCK_ANY]);
    return delegateMock;
}

- (void)testSyncInProgress {
    
    //If
    id assetsMock = OCMPartialMock(self.sut);
    MSAssetsDeploymentInstanceState *instanceState = [MSAssetsDeploymentInstanceState new];
    instanceState.syncInProgress = YES;
    [assetsMock setInstanceState:instanceState];
    id delegateMock = [self mockSyncDelegate];
    [assetsMock setDelegate:delegateMock];
    
    //When
    [assetsMock sync:[MSAssetsSyncOptions new]];
    
    //Then
    OCMVerify([delegateMock syncStatusChanged:MSAssetsSyncStatusSyncInProgress]);
}

- (void)testSyncError {
    
    //If
    NSError *remoteError = [[NSError alloc] init];
    MSAssetsSyncOptions *syncOptions = [MSAssetsSyncOptions new];
    [syncOptions setDeploymentKey:kMSDeploymentKey];
    MSAssetsConfiguration *configuration = [MSAssetsConfiguration new];
    id delegateMock = [self mockSyncDelegate];
    
    //When
    [self syncWithSyncOptions:syncOptions andConfiguration:configuration andLocalPackage:nil andInstanceState:nil andDelegate:delegateMock andRemotePackage:nil andRemoteError:remoteError downloadAndInstallError:nil];
    
    //Then
    OCMVerify([delegateMock syncStatusChanged:MSAssetsSyncStatusCheckingForUpdate]);
    OCMVerify([delegateMock syncStatusChanged:MSAssetsSyncStatusUnknownError]);
    XCTAssertEqual(self.sut.instanceState.syncInProgress, NO);
}


- (void)syncWithSyncOptions: (MSAssetsSyncOptions *) syncOptions
andConfiguration: (MSAssetsConfiguration *)configuration
            andLocalPackage: (MSAssetsLocalPackage *)localPackage
           andInstanceState: (MSAssetsDeploymentInstanceState *)instanceState
                andDelegate:(id<MSAssetsDelegate>)delegate
           andRemotePackage:(MSAssetsRemotePackage *)rmPackage
             andRemoteError:(NSError *)remoteError
    downloadAndInstallError:(NSError *)downloadAndInstallError {
    
    // If
    id assetsMock = OCMPartialMock(self.sut);
    OCMStub([assetsMock getCurrentPackage]).andReturn(localPackage);
    OCMStub([assetsMock getConfigurationWithError:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(configuration);
    if (instanceState != nil) {
        [assetsMock setInstanceState:instanceState];
    }
    OCMStub([assetsMock checkForUpdate:syncOptions.deploymentKey withCompletionHandler:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        MSCheckForUpdateCompletionHandler loadCallback;
        [invocation getArgument:&loadCallback atIndex:3];
        loadCallback(rmPackage, remoteError);
    });
    OCMStub([assetsMock doDownloadAndInstall:rmPackage syncOptions:syncOptions configuration:OCMOCK_ANY handler:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        MSAssetsDownloadInstallHandler loadCallback;
        [invocation getArgument:&loadCallback atIndex:5];
        loadCallback(downloadAndInstallError);
    });
    if (delegate != nil) {
        [assetsMock setDelegate:delegate];
    }
    
    // When
    [assetsMock sync:syncOptions];
    
    // Then
    OCMVerify([assetsMock checkForUpdate:syncOptions.deploymentKey withCompletionHandler:OCMOCK_ANY]);
    [assetsMock stopMocking];
}

@end

