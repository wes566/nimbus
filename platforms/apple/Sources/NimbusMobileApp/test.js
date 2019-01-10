var expect = chai.expect;

describe("Veil Test Suite", () => {
         
         // When all tests are done drop the entire html content(mocha result) back to native side
         // for further processing
         after(() => { window.webkit.messageHandlers.testFinished.postMessage(document.documentElement.outerHTML.toString()); });
         
         describe('Veil', () => {
                  it('can call native method', (done)=> {
                     DemoAppBridge.showAlert("Hello from javascript!").
                     then(() => {
                          done();
                          });
                     });
                  });

         describe('Veil', () => {
                  it('can call native method and get return value', (done)=> {
                     DemoAppBridge.currentTime()
                     .then((time) => {
                           var today = new Date();
                           var dateTime = new Date(Date.parse(time));
                           expect(dateTime.getMonth()).to.equal(today.getMonth());
                           expect(dateTime.getDate()).to.equal(today.getDate());
                           done();
                           });
                     });
                  });
         
         describe('Veil', () => {
                  it('can callback javascript', (done)=> {
                     DemoAppBridge.withCallback((v) => {
                                                expect(v).to.equal("hello from swift");
                                                done();
                                                });
                     });
                  });
});


//mocha.checkLeaks();
//mocha.run();
