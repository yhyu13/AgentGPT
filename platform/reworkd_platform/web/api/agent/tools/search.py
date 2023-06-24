from typing import Any, List

import aiohttp
from fastapi.responses import StreamingResponse as FastAPIStreamingResponse

from reworkd_platform.schemas import ModelSettings
from reworkd_platform.settings import settings
from reworkd_platform.web.api.agent.tools.stream_mock import stream_string
from reworkd_platform.web.api.agent.tools.tool import Tool
from reworkd_platform.web.api.agent.tools.utils import summarize

import json

# Search google via serper.dev. Adapted from LangChain
# https://github.com/hwchase17/langchain/blob/master/langchain/utilities


async def _google_serper_search_results(
    search_term: str, search_type: str = "search"
) -> dict[str, Any]:
    headers = {
        "X-API-KEY": settings.serp_api_key or "",
        "Content-Type": "application/json",
    }
    params = {
        "q": search_term,
    }

    async with aiohttp.ClientSession() as session:
        async with session.post(
            f"https://google.serper.dev/{search_type}", headers=headers, params=params
        ) as response:
            response.raise_for_status()
            search_results = await response.json()
            return search_results


class Search(Tool):
    description = (
        "Search Google for short up to date searches for simple questions "
        "news and people.\n"
        "The argument should be the search query."
    )
    public_description = "Search google for information about current events."

    @staticmethod
    def available() -> bool:
        return settings.serp_api_key is not None and settings.serp_api_key != ""

    async def call(
        self, goal: str, task: str, input_str: str
    ) -> FastAPIStreamingResponse:
        results = await _google_serper_search_results(
            input_str,
        )
        # yhyu13 : do not limit the number of results
        k = 999 #6 # Number of results to return
        max_links = 999 #3 # Number of links to return
        snippets: List[str] = []
        links: List[str] = []
        # yhyu13 : explicit store knwoledge graph
        knowledgeGraph: List[str] = []
        titles: List[str] = []

        if results.get("answerBox"):
            answer_values = []
            answer_box = results.get("answerBox", {})
            if answer_box.get("answer"):
                answer_values.append(answer_box.get("answer"))
            elif answer_box.get("snippet"):
                answer_values.append(answer_box.get("snippet").replace("\n", " "))
            elif answer_box.get("snippetHighlighted"):
                answer_values.append(", ".join(answer_box.get("snippetHighlighted")))

            if len(answer_values) > 0:
                return stream_string("\n".join(answer_values), True)

        if results.get("knowledgeGraph"):
            kg = results.get("knowledgeGraph", {})
            title = kg.get("title")
            entity_type = kg.get("type")
            if entity_type:
                knowledgeGraph.append(f"{title}: {entity_type}.")
            description = kg.get("description")
            if description:
                knowledgeGraph.append(description)
            for attribute, value in kg.get("attributes", {}).items():
                knowledgeGraph.append(f"{title} {attribute}: {value}.")
            print(f'add knowledgeGraph : {knowledgeGraph}')

        index = 0
        for result in results["organic"][:k]:
            data = {}
            attributes = []
            if "snippet" in result:
                data["snippet"] = result["snippet"]
            if "link" in result and "title" in result:
                links.append(result["link"])
                titles.append(result["title"])
            else:
                continue
            for attribute, value in result.get("attributes", {}).items():
                attributes.append(f"{attribute}: {value}")
            data["attribute"] = ",".join(attributes) if len(attributes) > 0 else ""
            
            data_str = f'[{index}] : {json.dumps(data)}'
            print(f'add snippet : {data_str}')
            snippets.append(data_str)
            index += 1
            
        if len(snippets) == 0:
            return stream_string("No good Google Search Result was found", True)
        links_str = "\n\nLinks:\n"
        for i in range(len(links)):
            links_str += f"[^{i}]: [{titles[i]}]({links[i]})\n"
        print(links_str)

        return summarize(self.model_settings, goal, task, snippets, knowledgeGraph, links_str)

        # TODO: Stream with formatting
        # return f"{summary}\n\nLinks:\n" + "\n".join([f"- {link}" for link in links])
