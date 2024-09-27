import datetime
from typing import Literal

import dotenv
from dotenv import dotenv_values
from langchain_community.callbacks import get_openai_callback
from langchain_core.messages import HumanMessage, BaseMessage, AIMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.tools import  tool
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph
from langgraph.prebuilt import ToolNode

from AgentState import BuilderAgentState
from TFBuilding import TFBuilder

dotenv.load_dotenv()
conf = dotenv_values("../../pythonProject1/.env")


def playbookgen(args, osType):
    llm = ChatOpenAI(temperature=0.1, model=conf["OP_MODEL"])
    prompt = ChatPromptTemplate.from_messages(
        [
            ("system",
             "Your task is to generate the content of an ansible playbook given the program names and OS of the system,"
             " prefer always freeware/opensource software if possible,"
             " select equivalent programs if not available for the given OS"
             " and respond only with the content, no extra comments"
             ),
            MessagesPlaceholder("os"),
            MessagesPlaceholder("args"),
        ]
    )
    pfinal = prompt.format_messages(
        args=[HumanMessage(content=args.__str__())],
        os=[HumanMessage(content="OS given: " + osType)]
    )
    res: BaseMessage = llm.invoke(pfinal)
    result = res.content.replace("```yaml","").replace("```","")
    return result


class Generator:
    builder = TFBuilder("tftest/jsonLimitation.txt", "tftest/provider.tf")

    def __init__(self):
        modeltype = conf["OP_MODEL"]
        data = ["dummyData", "data"]
        d = data[1]
        toolBuild = [self.createResource, self.addNotebook]
        self.llm_gen = ChatOpenAI(temperature=0.1, model=modeltype).bind_tools(toolBuild)
        tool_node_build = ToolNode(toolBuild)
        workflow = StateGraph(BuilderAgentState)
        workflow.add_node("builder_tools", tool_node_build)
        workflow.add_node("generator", self.generate)
        workflow.add_node("final_build", self.finishbuild)
        workflow.add_conditional_edges("generator", self.llm_next_move)
        workflow.add_edge("builder_tools", "generator")
        workflow.set_entry_point("generator")
        workflow.set_finish_point("final_build")
        self.graph = workflow.compile()

    @staticmethod
    def finishbuild(state: BuilderAgentState):
        Generator.builder.build()

    @staticmethod
    def generate(state: BuilderAgentState):
        mexs = state["messages"]
        builder = Generator.builder
        llm = state["llm"]
        limitmex = [HumanMessage(content=builder.getlimitations())]
        isomex = [HumanMessage(content=builder.isos.__str__())]

        prompt = ChatPromptTemplate.from_messages(
            [
                ("system",
                 "Your task is: given a cyber range description or scenario, to create the necessary vms and relative software "
                 " to make possible the scenario,"
                 " both tasks using the given tools;"
                 " when you are done creating resources just output a normal non-tool message."
                 "You can call multiple times the same tool to add more resources, the name must be unique. "
                 "Note that there are some limitation on available resources that will be provided "
                 "to you; if the request cannot meet the limits adjust accordingly."
                 "If the request is not inherent to the description just return \"ERROR\"."
                 ),
                MessagesPlaceholder("limits"),
                MessagesPlaceholder("availableisos"),
                MessagesPlaceholder("history")
            ]
        )
        pfinal = prompt.format_messages(limits=limitmex, availableisos=isomex, history=mexs)
        res: BaseMessage = llm.invoke(pfinal)
        return {"messages": [res]}

    @staticmethod
    def llm_next_move(state: BuilderAgentState) -> Literal["builder_tools", "final_build", "__end__"]:
        mex = state["messages"]
        last_mex: AIMessage = mex[-1]
        if last_mex.tool_calls:
            print("generator->tools")
            return "builder_tools"
        elif last_mex.content.lower() == "error":
            print("richiesta non riconosciuta, descrivi meglio l'infrastruttura e riprova")
            return "__end__"
        print("generator->finalbuild")
        return "final_build"

    @staticmethod
    @tool
    def createResource(name: str, iso: str, cores: int, ram: int, disktype: str, disksize: int, ip: str) -> str:
        """
        :param name: the name assigned to the resource
        :param iso: name of the iso image to use
        :param cores: number of cores to allocate
        :param ram: amount of ram (MegaBytes) to allocate
        :param disktype: type of disk controller, select between: "ide", "sata", "scsi", "virtio"
        :param disksize: amount of space in the disk (GB)
        :param ip: ip of the machine (use "ip=dhcp" to get automatically)
        :return: status message "ok" or resources exceeded during allocation
        """
        res = Generator.builder.addResource(name, iso, cores, ram, disktype, disksize, ip)
        return res

    @staticmethod
    @tool
    def addNotebook(resName: str, programs: list[str]):
        """
        :param resName: name of resources on which install the software
        :param programs: software names to install (possibly freeware / openSource)
        """
        ostype = Generator.builder.getOs(resName)
        playbookText = playbookgen(programs, ostype)
        Generator.builder.newPlaybook(resName, playbookText)

    def runGenerator(self, inpt):
        inputs = {"messages": [HumanMessage(content="here's the request:\n" + inpt)],
                  "llm": self.llm_gen}
        with get_openai_callback() as cb:
            try:
                for s in self.graph.stream(inputs, stream_mode="values"):
                    message = s["messages"][-1]
                    if isinstance(message, tuple):
                        print(message)
                    else:
                        message.pretty_print()
            finally:
                with open("./tftest/usages.txt", "a") as f:
                    f.write(datetime.datetime.today().strftime('%Y-%m-%d@%H_%M_%S'))
                    f.write(inputs["messages"][0].content+"\n")
                    f.write(f"total token: {cb.total_tokens} ; total cost: {cb.total_tokens / 1_000_000 * 5}\n\n")
                print(f"total token: {cb.total_tokens}")
                print(f"total cost: {cb.total_cost}")


g = Generator()
g.runGenerator(input("inserisci prompt>"))
