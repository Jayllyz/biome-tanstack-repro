import { Button } from "@base-ui/react/button";
import { Dialog } from "@base-ui/react/dialog";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({ component: Home });

function Home() {
	return (
		<Dialog.Root>
			<Dialog.Trigger render={<Button />}>Open</Dialog.Trigger>
			<Dialog.Portal>
				<Dialog.Popup>
					<Dialog.Title>Hello</Dialog.Title>
					<Dialog.Close>Close</Dialog.Close>
				</Dialog.Popup>
			</Dialog.Portal>
		</Dialog.Root>
	);
}
