import { useState } from 'react';
import '../Public.css';
import { FiCpu, FiLock, FiSettings, FiStar, FiGitBranch } from 'react-icons/fi';
import { BiLogoGithub} from 'react-icons/bi';
import { RiRobot2Fill, RiFlowChart, RiRocketLine, RiExchangeLine, RiOpenSourceFill } from 'react-icons/ri';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism';

export default function Home() {
  const [activeTab, setActiveTab] = useState(0);
  const [activeCodeTab, setActiveCodeTab] = useState('flow');
  const [activeFeatureTab, setActiveFeatureTab] = useState(0);

  const featureTabs = [
    {
      title: 'Agent Visualization',
      description: 'Design and monitor complex AI workflows with intuitive visualization tools. Track agent interactions and data flows in real-time for complete operational visibility.',
      image: '/images/visualizer.png',
      icon: <RiFlowChart className="home-tab-icon" />,
    },
    {
      title: 'Execution Monitoring',
      description: 'Monitor AI workflows in real-time with comprehensive execution details. Get instant insights into agent performance, task status, and system health from a unified dashboard.',
      image: '/images/monitoring.png',
      icon: <FiCpu className="home-tab-icon" />,
    },
    {
      title: 'Agent Training',
      description: 'Optimize AI agents for specific business tasks through our specialized training interface. Enhance performance through iterative learning and structured feedback loops.',
      image: '/images/training.png',
      icon: <RiRobot2Fill className="home-tab-icon" />,
    },
  ];

  const codeExamples = {
    flow: {
      file: 'Program.cs',
      code: `

      // Create the agent team with temporal.io workflow engine
      var agentTeam = new AgentTeam("SalesProspectingTeam");
      
      // Scheduler agent with fault-tolerant execution
      var schedulerAgent = agentTeam.AddAgent<SchedulerBot>();
      schedulerAgent.SetScheduleProcessor<SchedulerProcessor>(
          processInWorkflow: true, 
          startAutomatically: true, 
          runAtStart: true
      );
      schedulerAgent.AddActivities<ProspectingActivities>();
      
      // Content generation agent
      var contentAgent = agentTeam.AddAgent<ContentFlow>();
      contentAgent.AddActivities<ContentFlowActivities>();
      
      // Interactive assistant with MCP tools
      var assistantAgent = agentTeam.AddAgent<InteractionBot>();
      assistantAgent.AddCapabilities(typeof(SalesCapabilities));
      
      // Web research agent with MCP integration
      var webAgent = agentTeam.AddAgent<WebResearchBot>();
      webAgent.AddKernelModifier(new FirecrawlMCP());
      webAgent.AddKernelModifier(new GoogleSearchMCP());
      webAgent.AddKernelModifier(new PlaywrightMCP());
      
      // Reporting agent with Office 365 integration
      var reporterAgent = agentTeam.AddAgent<ReportingBot>();
      reporterAgent.AddKernelModifier(new MicrosoftO365MCP());
      reporterAgent.AddKernelModifier(new PdfGeneratorMCP());
      
      // Run with enterprise-grade reliability
      await agentTeam.RunAsync();
    `,
    },
    agentOne: {
      file: 'WebResearchAgent.cs',
      code: `

      [Workflow("Web Research Agent")]
      public class WebResearchAgent : FlowBase
      {
          public WebResearchAgent()
          {
              SystemPrompt = @"You are a specialized web research agent equipped 
              with MCP tools for comprehensive data gathering and analysis. 
              Your mission is to gather, process, and extract insights from web sources
              with fault-tolerant execution powered by temporal.io.
      
              ## Your MCP Capabilities
              - Firecrawl for web scraping
              - Playwright for browser automation  
              - Google Search for discovery
              - Content analysis and extraction
              ...";
          }
          
          [WorkflowRun]
          public async Task Run()
          {
              // Initialize with durable workflow execution
              await InitConversation();
              
              // Handle long-running research tasks
              await ProcessResearchQueue();
          }
      }
      
    `,
    },
    agentTwo: {
      file: 'SalesCapabilities.cs',
      code: `
 public class SalesCapabilities
{
    [Capability("Research prospect company information")]
    [Parameter("companyDomain", "Domain of the company to research")]
    [Returns("Comprehensive company research data")]
    public async Task<CompanyResearch> ResearchCompany(string companyDomain)
    {
        var instruction = $@"
        Research company: {companyDomain}
        
        Gather:
        - Company overview and recent news
        - Key personnel and decision makers  
        - Technology stack and tools used
        - Recent funding or growth indicators
        
        Use MCP tools: Firecrawl for scraping, Google Search for discovery.
        Return structured data for sales outreach.
        ";

        // Agent-to-Agent communication with fault tolerance
        var response = await MessageHub.Agent2Agent.SendChatWithRetry(
            typeof(WebResearchAgent), 
            instruction,
            retryPolicy: RetryPolicy.DefaultExponential
        );

        return JsonSerializer.Deserialize<CompanyResearch>(response.Text);
      }
      
      ...
}
    `,
    },
  };

  const featureCodeExamples = [
    `
// Temporal.io powered durability - workflows survive restarts
await Workflow.DelayAsync(TimeSpan.FromDays(365));
// Your workflow continues exactly where it left off after a year`,

    `[WorkflowSignal]
public async Task UserApproved(string comment)
{
    approval = true;
    approvalComment = comment;
    // User responded via chat interface
    // Continue workflow execution
}

// Wait for human-in-the-loop approval
await Workflow.WaitConditionAsync(() => approval);`,

    `
// Horizontal scaling across multiple machines/containers
await flowRunner.RunFlowAsync(flowInfo);
// Temporal.io handles load balancing and task distribution`,

    `// Enterprise-grade fault tolerance with exponential backoff
RetryPolicy = new() { 
    MaximumInterval = TimeSpan.FromSeconds(60),
    BackoffCoefficient = 2.0,
    MaximumAttempts = 5 
},`,

    `// Workflow state persisted automatically by temporal.io
var prospectingResults = new List<ProspectData>();
var processedCompanies = new HashSet<string>();`,
  ];

  const handleTabClick = (index) => setActiveFeatureTab(index);

    return (
        <div className="home-container">
      <a href="https://github.com/XiansAiPlatform" className="github-corner" aria-label="View on GitHub">
        <svg width="80" height="80" viewBox="0 0 250 250" aria-hidden="true">
          <path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path>
          <path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" className="octo-arm"></path>
          <path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" className="octo-body"></path>
        </svg>
      </a>

      <header className="home-header">
        <div className="home-header-content">
          <div className="home-logo-container">
            <div className="home-logo">
              <span className="home-logo-flow">Xians</span>
              <span className="home-logo-ai">.ai</span>
            </div>
            <a href="https://99x.io" target="_blank" rel="noopener noreferrer" className="home-logo-sub">
              <span className="home-logo-by">by</span>
              <img src="/images/99xlogo.svg" alt="99x" className="home-logo-99x" />
            </a>
          </div>
          <div className="home-nav-auth">
            <nav className="home-nav">
              <a href="https://xiansaiplatform.github.io/XiansAi.PublicDocs" target="_blank" rel="noopener noreferrer" className="home-nav-link">
                Documentation
              </a>
            </nav>
            <div className="home-auth-buttons" />
          </div>
        </div>
      </header>

            <section className="home-hero">
                <div className="home-hero-content">
          <div className="hero-badges">
            <a href="https://github.com/XiansAiPlatform" target="_blank" rel="noopener noreferrer" className="open-source-badge">
              <RiOpenSourceFill />
              Open Source
            </a>
            <a href="https://github.com/XiansAiPlatform" target="_blank" rel="noopener noreferrer" className="github-counter">
              <FiStar />
              <span>Star</span>
            </a>
            <a href="https://github.com/XiansAiPlatform" target="_blank" rel="noopener noreferrer" className="github-counter">
              <FiGitBranch />
              <span>Fork</span>
            </a>
                    </div>

          <h1 style={{ wordSpacing: '0.2em' }}>Enterprise-Grade AI Agent Development Kit</h1>

                        <div className="home-cta-buttons">
            <button className="home-btn home-btn-primary" onClick={() => window.open('https://github.com/XiansAiPlatform', '_blank')}>
                                <BiLogoGithub />
                                View on GitHub
                            </button>
            <button className="home-btn home-btn-secondary" onClick={() => window.open('https://xiansaiplatform.github.io/XiansAi.PublicDocs', '_blank')}>
                                Documentation
                            </button>
                        </div>

          <p className="home-hero-subtitle">
            Build fault-tolerant AI agent workflows with temporal.io reliability. Platform-agnostic architecture with MCP tool integration and multi-agent coordination.
          </p>

          <div style={{ marginTop: '2rem' }}>
            <code>{'>'} dotnet add package XiansAi.Lib</code>
          </div>
        </div>
      </section>

      <section className="home-feature-showcase">
        <div className="home-tab-buttons">
          {featureTabs.map((tab, index) => (
            <button key={index} className={`home-tab-button ${activeTab === index ? 'active' : ''}`} onClick={() => setActiveTab(index)}>
              {tab.icon}
              {tab.title}
            </button>
          ))}
        </div>

        <div className="home-feature-content">
          <div className="home-feature-image">
            <img src={featureTabs[activeTab].image} alt={featureTabs[activeTab].title} />
          </div>
          <div className="home-feature-text">
            <h2>{featureTabs[activeTab].title}</h2>
            <p>{featureTabs[activeTab].description}</p>
          </div>
        </div>
      </section>


      <section className="home-agent-composition">
        <div className="home-agent-composition-content">
          <div className="home-agent-composition-text">
            <h2>Agents in a Team</h2>
            <p className="home-agent-composition-subtitle">Case study – Sales Prospecting Agent Team</p>
            <p>
              Enterprise AI workflows require specialized agents working in coordination. Built on <strong>temporal.io</strong> for 
              fault-tolerant execution, agents communicate through <strong>MCP (Model Context Protocol)</strong> for tool integration and 
              <strong>Agent-to-Agent</strong> interactions for seamless handoffs between different capabilities.
            </p>
          </div>
          <div className="home-agent-composition-visual">
            <img src="/images/agent-team.png" alt="Agent Composition Architecture" className="home-agent-composition-image" />
          </div>
        </div>
      </section>

      <section className="home-code-demo">
        <div className="home-code-demo-content">
          <div className="home-code-demo-text">
            <h2>Create Your First Multi-Agent Team</h2>
            <p>Build enterprise-grade AI workflows with temporal.io reliability. Here's how to create a fault-tolerant sales prospecting agent team:</p>
            <div className="repo-activity-graph" title="Repository activity" />
            <ul className="home-code-demo-points">
              <li>Define specialized agents with MCP tool integration</li>
              <li>Coordinate Agent-to-Agent communication workflows</li>
              <li>Execute with temporal.io fault tolerance and durability</li>
            </ul>
          </div>
          <div className="home-code-demo-box">
            <div className="home-code-header">
              <div className="home-code-tabs">
                {Object.entries(codeExamples).map(([key, { file }]) => (
                  <button key={key} className={`home-code-tab ${activeCodeTab === key ? 'active' : ''}`} onClick={() => setActiveCodeTab(key)}>
                    {file}
                  </button>
                ))}
              </div>
            </div>
            <SyntaxHighlighter language="csharp" style={vscDarkPlus} className="home-code-block">
              {codeExamples[activeCodeTab].code}
            </SyntaxHighlighter>
          </div>
        </div>
        <br />
        <div className="home-code-demo-content" style={{ maxWidth: '800px', margin: '50px auto' }}>
          <div className="home-code-demo-box">
            <div className="home-code-header">
              <h3 style={{ textAlign: 'center', width: '100%' }}>Read documentation to get started</h3>
            </div>
            <div className="home-code-block" style={{ padding: '2rem', textAlign: 'center' }}>
              <p style={{ marginBottom: '1.5rem' }}>
                Learn more about the Xians.ai platform and how to use it's capabilities to build your own AI Agents and Workflows.
              </p>
              <a href="https://xiansaiplatform.github.io/XiansAi.PublicDocs" target="_blank" rel="noopener noreferrer" className="home-btn home-btn-primary" style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem' }}>
                <FiSettings className="feature-icon-svg" />
                Read Documentation
              </a>
            </div>
          </div>
        </div>
      </section>

      <section className="home-features">
        <div className="home-features-grid">
          <div className="home-feature-card-large">
            <h3>Escape Vendor Lock-In with Open Architecture</h3>
            <p>
              Deploy AI agents from any source—whether from Xians.ai, other providers, or your own development team. Any containerized agent integrates seamlessly with our platform.
            </p>
            <div className="home-tech-logos">
              <img src="/images/docker-logo.png" alt="Docker" className="home-tech-logo" />
              <img src="/images/kubernetes-logo.png" alt="Kubernetes" className="home-tech-logo" />
            </div>
          </div>

          <div className="home-feature-card-medium">
            <h3>Temporal.io Workflow Engine</h3>
            <p>
              Built on temporal.io for enterprise-grade reliability. Workflows survive restarts, handle failures gracefully, and scale horizontally across your infrastructure.
            </p>
            <div className="home-feature-code">
              <div className="home-feature-languages">
                {['Durable', 'Event Driven', 'Scalable', 'Fault Tolerant', 'Persistent State'].map((tab, index) => (
                  <button key={index} className={`home-feature-language ${activeFeatureTab === index ? 'active' : ''}`} onClick={() => handleTabClick(index)}>
                    {tab}
                  </button>
                ))}
              </div>
              <SyntaxHighlighter language="csharp" style={vscDarkPlus}>
                {featureCodeExamples[activeFeatureTab]}
              </SyntaxHighlighter>
            </div>
          </div>

          <div className="home-feature-card-medium">
            <h3>MCP Tool Ecosystem Integration</h3>
            <p>Leverage the growing MCP (Model Context Protocol) ecosystem with seamless tool integration for enterprise workflows.</p>
            <div className="home-feature-code">
              <SyntaxHighlighter language="csharp" style={vscDarkPlus}>
                {`
// MCP tools integrate seamlessly
webAgent.AddKernelModifier(new FirecrawlMCP());
webAgent.AddKernelModifier(new GoogleSearchMCP());
webAgent.AddKernelModifier(new PlaywrightMCP());

reporterAgent.AddKernelModifier(new MicrosoftO365MCP());
reporterAgent.AddKernelModifier(new PdfGeneratorMCP());
// Extensive MCP ecosystem support...
`}
              </SyntaxHighlighter>
            </div>
          </div>

          <div className="home-feature-card-large">
            <h3>Balance AI Autonomy with Human Control</h3>
            <ul className="home-code-demo-points">
              <li>Maintain control over critical business processes</li>
              <li>Implement AI automation strategically after review</li>
              <li>Keep human oversight in workflow design</li>
              <li>Blend autonomy and orchestration seamlessly</li>
            </ul>
          </div>

          <div className="home-feature-card-large">
            <h3>Sophisticated Agents, Not Just Chatbots</h3>
            <p>
              Our platform is designed to host sophisticated agents capable of executing complex tasks and workflows, far beyond simple chat interactions.
            </p>
            <br />
            <div className="home-feature-self-host">
              <div>
                <img src="/images/agent-anatomy.png" alt="Agent Anatomy" />
                <p>A workflow within an agent intelligently orchestrates between multiple tools that are augmented by prompts</p>
              </div>
              <div>
                <img src="/images/multi-workflow-agent.png" alt="Multi-Workflow Agent" />
                <span>Agents can consist of multiple workflows, some for user interaction, others for business process capabilities.</span>
              </div>
            </div>
          </div>

          <div className="home-feature-card-medium">
            <h3>Self-Host in Your Cloud</h3>
            <div className="home-feature-self-host">
              <div>
                <img src="/images/deployment.png" alt="Deployment Architecture" />
                <span>Agent Platform Deployment</span>
              </div>
              <p style={{ textAlign: 'left' }}>
                Deploy the Xians.ai platform and agents in your own infrastructure for complete control and compliance.
              </p>
              <div className="self-host-features">
                <div className="self-host-feature">
                  <div className="feature-icon">
                    <FiLock className="feature-icon-svg" />
                  </div>
                  <div className="feature-text">Keep sensitive data within your environment</div>
                </div>
                <div className="self-host-feature">
                  <div className="feature-icon">
                    <RiRocketLine className="feature-icon-svg" />
                  </div>
                  <div className="feature-text">Deploy as containers or app services</div>
                </div>
                <div className="self-host-feature">
                  <div className="feature-icon">
                    <RiExchangeLine className="feature-icon-svg" />
                  </div>
                  <div className="feature-text">Seamless integration with your existing cloud resources</div>
                </div>
                <div className="self-host-feature">
                  <div className="feature-icon">
                    <FiSettings className="feature-icon-svg" />
                  </div>
                  <div className="feature-text">Customize networking and security policies</div>
                </div>
              </div>
            </div>
          </div>
          <div className="home-feature-card-large">
            <h3>Built for Multi-Tenancy</h3>
            <p>
              Scale your AI operations across multiple customers with built-in tenant isolation. Deploy and manage agents per customer while maintaining unified oversight.
            </p>
            <ul className="home-code-demo-points">
              <li>Isolate agent execution between tenants</li>
              <li>Activate or deactivate agents on a per-tenant</li>
              <li>Maintain separate configurations for tenants</li>
              <li>Centralized monitoring across tenants</li>
            </ul>
            <div className="home-feature-image" style={{ maxHeight: '140px', display: 'flex', justifyContent: 'center', marginTop: '15px' }} />
          </div>
                </div>
            </section>

            <section className="home-comparison">
        <div className="home-comparison-content">
          <div className="home-comparison-text">
            <h2>Enterprise Agent Platform Comparison</h2>
            <p>See how Xians.ai compares to other enterprise AI agent development platforms:</p>
          </div>
          <div className="home-comparison-table-container">
            <table className="home-comparison-table">
              <thead>
                <tr>
                  <th></th>
                  <th>Xians.ai</th>
                  <th>Other Agent Kits</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Multi-Agent Coordination</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-check">✓</span></td>
                </tr>
                <tr>
                  <td>Agent-to-Agent Communication</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-check">✓</span></td>
                </tr>
                <tr>
                  <td>Temporal.io Workflow Engine</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Durable Workflow Execution</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Long-running Process Support</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>MCP Tool Integration</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-check">✓</span></td>
                </tr>
                <tr>
                  <td>Event-driven Architecture</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Multi-tenancy Support</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Platform Agnostic</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-check">✓</span></td>
                </tr>
                <tr>
                  <td>Enterprise Fault Tolerance</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Workflow Visualization</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Self-hosted Deployment</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-check">✓</span></td>
                </tr>
                <tr>
                  <td>Workflow State Persistence</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Management Portal</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Prompt Base Management</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Execution History & Tracing</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
                <tr>
                  <td>Horizontal Scaling</td>
                  <td><span className="comparison-check">✓</span></td>
                  <td><span className="comparison-question">?</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <footer className="home-footer">
        <div className="home-footer-content">
          <div className="home-footer-left">
            <div className="home-footer-logo">
              <span className="home-logo-flow">Xians</span>
              <span className="footer-logo-ai">.ai</span>
            </div>
            <span className="home-footer-copyright">© {new Date().getFullYear()} Xians.ai. All rights reserved.</span>
          </div>
          <div className="home-footer-right">
            <div className="home-footer-links">
              <a href="/" className="home-footer-link">Privacy Policy</a>
              <a href="/" className="home-footer-link">Terms of Service</a>
              <a href="https://github.com/XiansAiPlatform" target="_blank" rel="noopener noreferrer" className="home-footer-link">
                <BiLogoGithub className="home-footer-icon" />
                GitHub
              </a>
            </div>
          </div>
        </div>
      </footer>
        </div>
    );
}

