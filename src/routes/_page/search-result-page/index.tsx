import {createFileRoute} from '@tanstack/react-router'
import {SearchResultPage} from "@/pages";


export const Route = createFileRoute('/_page/search-result-page/')({
    shouldReload: false,
    component: SearchResultPage
})